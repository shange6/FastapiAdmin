import request from "@/utils/request";

const API_PATH = "/produce/manhour";

const ProduceManhourAPI = {
  // 列表查询
  listProduceManhour(query: ProduceManhourPageQuery) {
    return request<ApiResponse<PageResult<ProduceManhourTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 详情查询
  detailProduceManhour(id: number) {
    return request<ApiResponse<ProduceManhourTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 新增
  createProduceManhour(body: ProduceManhourForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateProduceManhour(id: number, body: ProduceManhourForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceManhour(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchProduceManhour(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportProduceManhour(query: ProduceManhourPageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceManhour() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceManhour(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default ProduceManhourAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface ProduceManhourPageQuery extends PageQuery {
  name?: string;
  model?: string;
  material?: string;
  unit?: string;
  unit_hour?: number;
  blanking_ratio?: number;
  welding_ratio?: number;
  fitting_ratio?: number;
  created_id?: number;
  updated_id?: number;
  created_time?: string[];
  updated_time?: string[];
  order_by?: string;
}

// 列表展示项
export interface ProduceManhourTable extends BaseType {
  name?: string;
  model?: string;
  material?: string;
  unit?: string;
  unit_hour?: number;
  blanking_ratio?: number;
  welding_ratio?: number;
  fitting_ratio?: number;
  created_id?: string;
  updated_id?: string;
  created_by?: CommonType;
  updated_by?: CommonType;
  inputNumber?: number;
}

// 新增/修改/详情表单参数
export interface ProduceManhourForm extends BaseFormType {
  name?: string;
  model?: string;
  material?: string;
  unit?: string;
  unit_hour?: number;
  blanking_ratio?: number;
  welding_ratio?: number;
  fitting_ratio?: number;
}
