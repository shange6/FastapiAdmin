import request from "@/utils/request";

const API_PATH = "/produce/craftroute";

const ProduceCraftRouteAPI = {
  // 列表查询
  listProduceCraftRoute(query: ProduceCraftRoutePageQuery) {
    return request<ApiResponse<PageResult<ProduceCraftRouteTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 获取全部工艺路线（不分页）
  getAllProduceCraftRoute() {
    return request<ApiResponse<ProduceCraftRouteTable[]>>({
      url: `${API_PATH}/list/all`,
      method: "get",
    });
  },

  // 查询工艺路线视图列表（聚合后的数据）
  getCraftRouteViewList(query: { route_name?: string }) {
    return request<ApiResponse<CraftRouteView[]>>({
      url: `${API_PATH}/view/list`,
      method: "get",
      params: query,
    });
  },

  // 详情查询
  detailProduceCraftRoute(route: number) {
    return request<ApiResponse<PageResult<any[]>>>({
      url: `${API_PATH}/detail/route/${route}`,
      method: "get",
    });
  },

  // 新增
  createProduceCraftRoute(body: ProduceCraftRouteForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateProduceCraftRoute(id: number, body: ProduceCraftRouteForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceCraftRoute(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchProduceCraftRoute(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportProduceCraftRoute(query: ProduceCraftRoutePageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceCraftRoute() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceCraftRoute(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default ProduceCraftRouteAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface ProduceCraftRoutePageQuery extends PageQuery {
  route?: number;
  sort?: string;
  craft_id?: string;
  status?: string;
  created_id?: number;
  updated_id?: number;
  created_time?: string[];
  updated_time?: string[];
}

// 列表展示项
export interface ProduceCraftRouteTable extends BaseType {
  route?: number;
  craft_names?: string;
  sort?: string;
  craft_id?: string;
  created_id?: string;
  updated_id?: string;
  created_by?: CommonType;
  updated_by?: CommonType;
}

// 工艺路线视图
export interface CraftRouteView {
  route_code: number;
  route_name: string;
}

// 新增/修改/详情表单参数
export interface ProduceCraftRouteForm extends BaseFormType {
  route?: number;
  sort?: string;
  craft_id?: string;
}
