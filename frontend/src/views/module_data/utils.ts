/**
 * 转换扁平BOM列表为树形结构
 * @param list 原始扁平列表（要求父节点在子节点之前）
 * @param projectCode 项目代号
 * @param firstCode 根代号
 * @returns { tree: any[], errors: string[] }
 */
export function convertToTree(list: any[], projectCode?: string, firstCode?: string) {
  if (!list || list.length === 0) return { tree: [], errors: [] };

  const tree: any[] = [];
  const errors: string[] = [];
  
  // 1. 初始化节点并保留原始顺序
  const nodes = list.map((item, index) => ({
    ...item,
    _tree_id: item.id || `node_${index}`,
    children: [],
  }));

  // 记录处理路径用于循环引用检测
  const pathMap = new Map<string, string[]>();

  nodes.forEach((node, index) => {
    // 2. 根节点判定逻辑
    const isRoot = (firstCode && node.code === firstCode) || 
                   (projectCode && node.parent_code === projectCode);

    if (isRoot) {
      tree.push(node);
      pathMap.set(node._tree_id, [node.code]);
      return;
    }

    // 3. 寻找父节点：逆序向后查找最近的 code 等于 parent_code 的记录
    let foundParentNode: any = null;
    for (let i = index - 1; i >= 0; i--) {
      if (nodes[i].code === node.parent_code) {
        // 借用件判断逻辑
        if (nodes[i].borrow && !node.borrow) {
          continue; 
        }
        foundParentNode = nodes[i];
        break;
      }
    }

    if (foundParentNode) {
      // 4. 循环引用检测
      const parentPath = pathMap.get(foundParentNode._tree_id) || [];
      if (parentPath.includes(node.code)) {
        const errorMsg = `[致命错误] <span style="color: red">检测到循环引用：节点 ${node.code} 已存在于路径 ${parentPath.join(' -> ')} 中</span>`;
        errors.push(errorMsg);
        tree.push(node); 
      } else {
        foundParentNode.children.push(node);
        pathMap.set(node._tree_id, [...parentPath, node.code]);
      }
    } else {
      // 5. 找不到父级则引发错误
      const errorMsg = `[错误] <span style="color: red">零件 ${node.code} (${node.spec || '未知名称'}) 找不到符合条件的父级 ${node.parent_code}</span>`;
      errors.push(errorMsg);
      tree.push(node); 
    }
  });

  // 6. 处理节点排序和清理
  const processNodes = (nodes: any[]) => {
    nodes.sort((a, b) => {
      const aVal = a.procure ? 1 : 0;
      const bVal = b.procure ? 1 : 0;
      return aVal - bVal;
    });

    nodes.forEach((node) => {
      if (node.children && node.children.length === 0) {
        delete node.children;
      } else if (node.children) {
        processNodes(node.children);
      }
    });
  };
  
  processNodes(tree);
  return { tree, errors };
}

/**
 * 增强版：基于搜索条件过滤BOM，并补全匹配项的所有父节点
 * @param allBoms 全量原始数据
 * @param filterFn 自定义过滤函数
 * @param rootCode 强制包含的根节点代号（可选）
 * @returns 补全了父节点的扁平数组
 */
export function getMatchedBomsWithParents(
  allBoms: any[], 
  filterFn: (item: any) => boolean, 
  rootCode?: string
) {
  // 1. 建立 Map 索引 (O(1) 查找) 并记录原始索引
  const bomMapByCode = new Map<string, { item: any, index: number }>();
  allBoms.forEach((item, index) => {
    if (item.code && !bomMapByCode.has(item.code)) {
      bomMapByCode.set(item.code, { item, index });
    }
  });

  // 2. 执行初步过滤
  const filtered = allBoms.filter(item => {
    if (rootCode && item.code === rootCode) return true;
    return filterFn(item);
  });

  // 3. 准备结果容器，记录项及其对应的原始索引以供排序
  const finalMap = new Map<number | string, { item: any, index: number }>();
  
  // 获取项原始索引的辅助函数
  const getOrigInfo = (code: string) => bomMapByCode.get(code);

  filtered.forEach(item => {
    const info = getOrigInfo(item.code);
    if (info) finalMap.set(item.id || item.code, info);
  });

  // 4. 递归向上补全父节点
  const addParents = (bom: any) => {
    if (bom.parent_code) {
      const parentInfo = getOrigInfo(bom.parent_code);
      if (parentInfo) {
        const pKey = parentInfo.item.id || parentInfo.item.code;
        if (!finalMap.has(pKey)) {
          finalMap.set(pKey, parentInfo);
          addParents(parentInfo.item); 
        }
      }
    }
  };

  filtered.forEach(addParents);

  // --- 关键修复：按照原始索引 index 进行升序排序 ---
  // 确保父节点永远排在子节点前面，满足 convertToTree 的前提条件
  return Array.from(finalMap.values())
    .sort((a, b) => a.index - b.index)
    .map(val => val.item);
}


