import request from "@/utils/request";

const API_PATH = "/produce/bomroute";

const ProduceBomRouteAPI = {
  // 列表查询
  listProduceBomRoute(query: ProduceBomRoutePageQuery) {
    return request<ApiResponse<PageResult<ProduceBomRouteTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 获取全部（不分页）
  getAllProduceBomRoute() {
    return request<ApiResponse<ProduceBomRouteTable[]>>({
      url: `${API_PATH}/list/all`,
      method: "get",
    });
  },

  // 详情查询
  detailProduceBomRoute(id: number) {
    return request<ApiResponse<ProduceBomRouteTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 按项目统计未配置路线的BOM数量
  summaryMissingRoutesByProject(projectCode: string) {
    return request<ApiResponse<Record<string, number>>>({
      url: `${API_PATH}/summary/missing/${projectCode}`,
      method: "get",
    });
  },

  // 统计所有项目缺失路线数量
  summaryAllProjectsMissingRoutes() {
    return request<ApiResponse<Record<string, number>>>({
      url: `${API_PATH}/summary/missing/all`,
      method: "get",
    });
  },

  // 根据项目ID统计缺失路线数量（返回差额）
  summaryMissingRoutesCountByProjectId(projectId: number) {
    return request<ApiResponse<{ project_id: number; missing_count: number }>>({
      url: `${API_PATH}/summary/missing/count/by-project-id/${projectId}`,
      method: "get",
    });
  },

  // 根据first_id统计缺失路线数量（返回差额）
  summaryMissingRoutesCountByFirstId(firstId: number) {
    return request<ApiResponse<{ first_id: number; missing_count: number }>>({
      url: `${API_PATH}/summary/missing/count/by-first-id/${firstId}`,
      method: "get",
    });
  },

  // 新增
  createProduceBomRoute(body: ProduceBomRouteForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 插入或更新（如果已存在则更新，不存在则创建）
  upsertProduceBomRoute(bom_id: number, route: number) {
    return request<ApiResponse>({
      url: `${API_PATH}/upsert`,
      method: "post",
      data: { bom_id, route },
    });
  },

  // 批量插入或更新（合并为单条SQL执行）
  upsertBatchProduceBomRoute(data: { bom_id: number; route: number; project_code?: string; first_code?: string }[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/upsert/batch`,
      method: "post",
      data,
    });
  },

  // 修改（带主键）
  updateProduceBomRoute(id: number, body: ProduceBomRouteForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceBomRoute(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchProduceBomRoute(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportProduceBomRoute(query: ProduceBomRoutePageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceBomRoute() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceBomRoute(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default ProduceBomRouteAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface ProduceBomRoutePageQuery extends PageQuery {
  created_time?: string[];
  updated_time?: string[];
}

// 列表展示项
export interface ProduceBomRouteTable extends BaseType {
  bom_id?: number;
  route?: number;
  created_by?: CommonType;
  updated_by?: CommonType;
}

// 新增/修改/详情表单参数
export interface ProduceBomRouteForm extends BaseFormType {
  bom_id?: number;
  route?: number;
}
