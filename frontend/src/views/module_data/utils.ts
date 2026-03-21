/**
 * 转换扁平BOM列表为树形结构
 * @param list 原始扁平列表
 * @param projectCode 项目代号
 * @param firstCode 根代号
 * @returns { tree: any[], errors: string[] }
 */
export function convertToTree(list: any[], projectCode?: string, firstCode?: string) {
  if (!list || list.length === 0) return { tree: [], errors: [] };

  const tree: any[] = [];
  const errors: string[] = [];
  const nodes = list.map((item, index) => ({
    ...item,
    _tree_id: item.id || `node_${index}`, // 优先使用数据库 ID，否则使用临时 ID
    children: [],
  }));

  // 使用 code 作为映射，记录所有具有相同 code 的节点列表
  const nodesByCode: Record<string, any[]> = {};
  nodes.forEach((node) => {
    if (!nodesByCode[node.code]) nodesByCode[node.code] = [];
    nodesByCode[node.code].push(node);
  });

  nodes.forEach((node) => {
    // 根节点判断：如果代号等于 first_code，或者是项目代号，或者是自身
    if (firstCode && node.code === firstCode) {
      tree.push(node);
      return;
    }
    if (projectCode && node.parent_code === projectCode) {
      tree.push(node);
      return;
    }
    if (node.code === node.parent_code) {
      tree.push(node);
      return;
    }

    const candidates = nodesByCode[node.parent_code] || [];
    let foundParent = false;

    // 在候选父节点中寻找合适的挂载点
    for (const parent of candidates) {
      if (node._tree_id === parent._tree_id) continue;

      // 借用件判断逻辑：借用件(borrow=true)不能作为非借用件(borrow=false)的父级
      if (parent.borrow && !node.borrow) {
        continue; // 寻找下一个候选父节点
      }

      parent.children.push(node);
      foundParent = true;
      break;
    }

    if (!foundParent) {
      // 报错逻辑：如果没有找到符合条件的父节点，且不是已知的根节点
      const errorMsg = `[错误] <span style="color: red">零件 ${node.code} (${node.spec}) 找不到符合条件的父级 ${node.parent_code}</span>`;
      errors.push(errorMsg);
      tree.push(node); // 作为顶层节点展示，避免丢失数据
    }
  });

  // 处理节点排序和清理
  const processNodes = (nodes: any[]) => {
    nodes.sort((a, b) => {
      if (a.procure === b.procure) return 0;
      return a.procure ? 1 : -1;
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
