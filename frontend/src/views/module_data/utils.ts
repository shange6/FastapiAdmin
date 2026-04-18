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
  
  // 1. 初始化节点
  const nodes = list.map((item) => ({
    ...item,
    children: [],
  }));

  // 2. 为了支持无序列表，先建立 code 到节点的映射
  const codeMap = new Map<string, any>();
  nodes.forEach(node => {
    if (node.code) codeMap.set(node.code, node);
  });

  // 记录处理路径用于循环引用检测
  const pathMap = new Map<any, string[]>();

  nodes.forEach((node) => {
    // 3. 根节点判定逻辑
    const isRoot = (firstCode && node.code === firstCode) || 
                   (projectCode && node.parent_code === projectCode);

    if (isRoot) {
      tree.push(node);
      pathMap.set(node.id, [node.code]);
      return;
    }

    // 4. 寻找父节点
    const foundParentNode = codeMap.get(node.parent_code);

    if (foundParentNode) {
      // 5. 循环引用检测
      // const parentPath = pathMap.get(foundParentNode.id) || [];
      // if (parentPath.includes(node.code)) {
      //   const errorMsg = `[致命错误] <span style="color: red">检测到循环引用：节点 ${node.code} 已存在于路径 ${parentPath.join(' -> ')} 中</span>`;
      //   errors.push(errorMsg);
      //   tree.push(node); 
      // } else {
        foundParentNode.children.push(node);
      //   pathMap.set(node.id, [...parentPath, node.code]);
      // }
    } else {
      // 6. 找不到父级则作为顶层节点显示并引发错误
      const errorMsg = `[错误] <span style="color: red">零件 ${node.code} (${node.spec || '未知名称'}) 找不到符合条件的父级 ${node.parent_code}</span>`;
      errors.push(errorMsg);
      tree.push(node); 
    }
  });

  // 7. 处理节点排序和清理
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
 * 转换扁平BOM列表为树形结构 (专用于文件解析)
 * 1. 移除循环引用检测
 * 2. 采用逆序查找父节点方式，更适合处理有序但可能存在重复代号的文件数据
 * @param list 原始扁平列表
 * @param projectCode 项目代号
 * @param firstCode 根代号
 * @returns { tree: any[], errors: string[] }
 */
export function convertToTreeForFile(list: any[], projectCode?: string, firstCode?: string) {
  if (!list || list.length === 0) return { tree: [], errors: [] };

  const errors: string[] = [];
  
  // 1. 初始化节点，保留原始顺序
  const nodes = list.map((item, index) => ({
    ...item,
    // 如果没有 id，生成一个临时的 _tree_id
    id: item.id || `temp_${index}`,
    children: [],
  }));

  const tree: any[] = [];

  nodes.forEach((node, index) => {
    // 2. 根节点判定逻辑
    const isRoot = (firstCode && node.code === firstCode) || 
                   (projectCode && node.parent_code === projectCode);

    if (isRoot) {
      tree.push(node);
      return;
    }

    // 3. 寻找父节点：从当前位置逆序向前查找最近的符合条件的父级
    // 这种方式能解决同代号在不同层级出现的问题
    let foundParentNode: any = null;
    for (let i = index - 1; i >= 0; i--) {
      if (nodes[i].code === node.parent_code) {
        foundParentNode = nodes[i];
        break;
      }
    }

    if (foundParentNode) {
      foundParentNode.children.push(node);
    } else {
      // 4. 找不到父级则作为顶层节点显示并记录错误
      const errorMsg = `[错误] <span style="color: red">零件 ${node.code} (${node.spec || '未知名称'}) 找不到符合条件的父级 ${node.parent_code}</span>`;
      errors.push(errorMsg);
      tree.push(node); 
    }
  });

  // 5. 排序逻辑 (可选，通常文件解析保持原始顺序即可)
  const processNodes = (nodes: any[]) => {
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
  // 1. 为所有项建立索引并记录原始位置
  // 使用 Map 存储 code 到项的映射（用于查找父级）
  // 注意：在文件解析场景下，同 code 记录可能有多条，这里默认取第一条作为补全父级的参考
  const bomMapByCode = new Map<string, any>();
  
  // 预处理：确保所有项都有一个唯一的临时标识（如果数据库 ID 不存在）
  const indexedBoms = allBoms.map((item, index) => {
    const uniqueKey = item.id || `idx_${index}`;
    if (item.code && !bomMapByCode.has(item.code)) {
      bomMapByCode.set(item.code, { ...item, _search_key: uniqueKey });
    }
    return { ...item, _search_key: uniqueKey };
  });

  // 2. 执行初步过滤
  const filtered = indexedBoms.filter(item => {
    if (rootCode && item.code === rootCode) return true;
    return filterFn(item);
  });

  // 3. 准备结果容器，使用 _search_key 进行去重
  const finalMap = new Map<string | number, any>();

  filtered.forEach(item => {
    finalMap.set(item._search_key, item);
  });

  // 4. 递归向上补全父节点
  const addParents = (bom: any) => {
    if (bom.parent_code) {
      const parent = bomMapByCode.get(bom.parent_code);
      if (parent) {
        if (!finalMap.has(parent._search_key)) {
          finalMap.set(parent._search_key, parent);
          addParents(parent);
        }
      }
    }
  };

  filtered.forEach(addParents);

  // 5. 返回匹配项及其父节点的扁平数组，保持原始顺序
  const finalKeys = new Set(finalMap.keys());
  return indexedBoms
    .filter(item => finalKeys.has(item._search_key))
    .map(({ _search_key, ...item }) => item); // 移除临时标识
}


