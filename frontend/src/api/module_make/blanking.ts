import request from "@/utils/request";

const API_PATH = "/make/blanking";

const ProduceMakeAPI = {
  // 列表查询
  listProduceMake(query: ProduceMakePageQuery) {
    return request<ApiResponse<PageResult<ProduceMakeTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 详情查询
  detailProduceMake(id: number) {
    return request<ApiResponse<ProduceMakeTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 新增
  createProduceMake(body: ProduceMakeForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateProduceMake(id: number, body: ProduceMakeForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceMake(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchProduceMake(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportProduceMake(query: ProduceMakePageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceMake() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceMake(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default ProduceMakeAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface ProduceMakePageQuery extends PageQuery {
  bom_id?: string;
  order_no?: string;
  project_code?: string;
  current_sort?: string;
  current_craft_id?: string;
  status?: string;
  created_id?: number;
  updated_id?: number;
  created_time?: string[];
  updated_time?: string[];
}

// 列表展示项
export interface ProduceMakeTable extends BaseType {
  bom_id?: string;
  order_no?: string;
  project_code?: string;
  current_sort?: string;
  current_craft_id?: string;
  created_id?: string;
  updated_id?: string;
  created_by?: CommonType;
  updated_by?: CommonType;
}

// 新增/修改/详情表单参数
export interface ProduceMakeForm extends BaseFormType {
  bom_id?: string;
  order_no?: string;
  project_code?: string;
  current_sort?: string;
  current_craft_id?: string;
}
