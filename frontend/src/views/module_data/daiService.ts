// daiService.ts
import DataProjectAPI from "@/api/module_data/project";
import DataBomAPI from "@/api/module_data/bom";
import ProduceOrderAPI from "@/api/module_produce/order";
import ProduceMakeAPI from "@/api/module_make/blanking";
import ProduceBomRouteAPI from "@/api/module_produce/bomroute";
import ProduceBomManhourAPI from "@/api/module_produce/bommanhour";

/**
 * 逻辑 A：获取生产待处理的项目列表
 */
export async function getProductionProjectList(params: any) {
  const response = await DataProjectAPI.getAllDataProject(params);
  const data = response.data.data || [];
  // 转换：将后端原始字段 dai_count 映射为前端约定的 dai_project
  return data.map((item: any) => ({
    ...item,
    dai_project: item.dai_count || 0
  }));
}

/**
 * 逻辑 C：获取路线缺失的项目列表
 */
export async function getMissingRouteProjectList(params: any) {
  // 1. 获取所有项目
  const response = await DataProjectAPI.getAllDataProject(params);
  const projects = response.data.data || [];

  // 2. 批量获取每个项目的缺失路线数量差额
  const projectMissingPromises = projects
    .filter((item: any) => item.id)
    .map(async (item: any) => {
      try {
        const res = await ProduceBomRouteAPI.summaryMissingRoutesCountByProjectId(item.id);
        return {
          id: item.id,
          missing_count: res.data?.data?.missing_count || 0
        };
      } catch (e) {
        return { id: item.id, missing_count: 0 };
      }
    });

  const projectMissingResults = await Promise.all(projectMissingPromises);
  const missingCountMap = new Map(projectMissingResults.map(r => [r.id, r.missing_count]));

  // 3. 映射到 dai_project 字段
  return projects.map((item: any) => ({
    ...item,
    dai_project: item.id ? (missingCountMap.get(item.id) || 0) : 0
  }));
}

/**
 * 逻辑 A：获取生产待处理的 BOM 预览列表
 */
export async function getProductionBomPreview(projectCode: string, showOrderColumn: boolean, craftId: number) {
  // 1. 获取基础 BOM 列表
  const res = await DataBomAPI.listProjectBoms(projectCode);
  let boms = (res.data.data || []);

  if (boms.length === 0) return [];

  // 2. 如果需要显示单号，则获取单号
  if (showOrderColumn) {
    const bomIds = boms.map(b => Number(b.id)).filter(id => id > 0);
    const orderRes = await ProduceOrderAPI.summaryBatchProduceOrder({ bom_ids: bomIds });
    const orderMap = orderRes.data?.data || {};
    boms.forEach(b => {
      if (b.id) b.no = orderMap[String(b.id)] || "";
    });
  }

  // 3. 获取 BOM 级的待处理数 (dai_bom)
  const orderNos = boms.map(b => b.no).filter(Boolean) as string[];
  if (orderNos.length > 0) {
    const daiRes = await ProduceMakeAPI.summaryProduceMakeByOrders(orderNos, craftId);
    const daiMap = daiRes.data?.data || {};
    boms = boms.map(b => ({
      ...b,
      dai_bom: b.no ? (daiMap[b.no] || 0) : 0
    }));
  }

  return boms;
}

/**
 * 逻辑 C：获取路线缺失的 BOM 预览列表
 */
export async function getMissingRouteBomPreview(projectCode: string | undefined) {
  if (!projectCode) return []
  // 1. 获取第一层级基础 BOM 列表 (逻辑同 getProductionBomPreview 第一步)
  const res = await DataBomAPI.listProjectBoms(projectCode);
  let boms = (res.data.data || []);

  if (boms.length === 0) return [];

  // 2. 批量获取每个 BOM 的缺失路线数量差额
  const bomMissingPromises = boms
    .filter((b: any) => b.id)
    .map(async (b: any) => {
      try {
        // 调用新的后端接口，根据 first_id（BOM在data_bom表中的id）统计缺失数量
        const res = await ProduceBomRouteAPI.summaryMissingRoutesCountByFirstId(b.id);
        return {
          id: b.id,
          missing_count: res.data?.data?.missing_count || 0
        };
      } catch (e) {
        return { id: b.id, missing_count: 0 };
      }
    });

  const bomMissingResults = await Promise.all(bomMissingPromises);
  const missingCountMap = new Map(bomMissingResults.map(r => [r.id, r.missing_count]));

  // 3. 将汇总数据映射回第一层级 BOM 列表的 dai_bom 字段
  boms = boms.map((b: any) => ({
    ...b,
    dai_bom: b.id ? (missingCountMap.get(b.id) || 0) : 0
  }));

  return boms;
}

/**
 * 逻辑 D：获取工时缺失的项目列表
 */
export async function getMissingManhourProjectList(params: any) {
  // 1. 获取所有项目
  const response = await DataProjectAPI.getAllDataProject(params);
  const projects = response.data.data || [];

  // 2. 批量获取每个项目的缺失工时数量差额
  const projectMissingPromises = projects
    .filter((item: any) => item.id)
    .map(async (item: any) => {
      try {
        const res = await ProduceBomManhourAPI.summaryMissingManhourCountByProjectId(item.id);
        return {
          id: item.id,
          missing_count: res.data?.data?.missing_count || 0
        };
      } catch (e) {
        return { id: item.id, missing_count: 0 };
      }
    });

  const projectMissingResults = await Promise.all(projectMissingPromises);
  const missingCountMap = new Map(projectMissingResults.map(r => [r.id, r.missing_count]));

  // 3. 映射到 dai_project 字段
  return projects.map((item: any) => ({
    ...item,
    dai_project: item.id ? (missingCountMap.get(item.id) || 0) : 0
  }));
}

/**
 * 逻辑 D：获取工时缺失的 BOM 预览列表
 */
export async function getMissingManhourBomPreview(projectCode: string | undefined) {
  if (!projectCode) return []
  // 1. 获取第一层级基础 BOM 列表
  const res = await DataBomAPI.listProjectBoms(projectCode);
  let boms = (res.data.data || []);

  if (boms.length === 0) return [];

  // 2. 批量获取每个 BOM 的缺失工时数量差额
  const bomMissingPromises = boms
    .filter((b: any) => b.id)
    .map(async (b: any) => {
      try {
        const res = await ProduceBomManhourAPI.summaryMissingManhourCountByFirstId(b.id);
        return {
          id: b.id,
          missing_count: res.data?.data?.missing_count || 0
        };
      } catch (e) {
        return { id: b.id, missing_count: 0 };
      }
    });

  const bomMissingResults = await Promise.all(bomMissingPromises);
  const missingCountMap = new Map(bomMissingResults.map(r => [r.id, r.missing_count]));

  // 3. 将汇总数据映射回第一层级 BOM 列表的 dai_bom 字段
  boms = boms.map((b: any) => ({
    ...b,
    dai_bom: b.id ? (missingCountMap.get(b.id) || 0) : 0
  }));

  return boms;
}

/**
 * 逻辑 B：示例 - 质量检测逻辑 (未来扩展)
 */
export async function getQualityProjectList(params: any) {
  const response = await DataProjectAPI.getAllDataProject(params);
  return response.data.data.map((item: any) => ({
    ...item,
    dai_project: 88 // 假设这是质量相关的逻辑
  }));
}