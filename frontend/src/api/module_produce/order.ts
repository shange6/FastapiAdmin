import request from "@/utils/request";

const API_PATH = "/produce/order";

const ProduceOrderAPI = {
  // 列表查询
  listProduceOrder(query: ProduceOrderPageQuery) {
    return request<ApiResponse<PageResult<ProduceOrderTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 批量查询工单单号（按BOM ID汇总）
  summaryBatchProduceOrder(body: { bom_ids: number[] }) {
    return request<ApiResponse<Record<string, string>>>({
      url: `${API_PATH}/summary/batch`,
      method: "post",
      data: body,
    });
  },

  // 详情查询
  detailProduceOrder(id: number) {
    return request<ApiResponse<ProduceOrderTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 新增
  createProduceOrder(body: ProduceOrderForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateProduceOrder(id: number, body: ProduceOrderForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceOrder(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchProduceOrder(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportProduceOrder(query: ProduceOrderPageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceOrder() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceOrder(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },

  // 批量保存（存在则更新）
  upsertBatchProduceOrder(body: { items: ProduceOrderForm[] }) {
    return request<ApiResponse>({
      url: `${API_PATH}/upsert/batch`,
      method: "post",
      data: body,
    });
  },
};

export default ProduceOrderAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface ProduceOrderPageQuery extends PageQuery {
  bom_id?: string;
  craft_id?: string;
  man_hour?: string;
  plan_count?: string;
  real_count?: string;
  plan_date?: string;
  real_date?: string;
  status?: string;
  created_id?: number;
  updated_id?: number;
  created_time?: string[];
  updated_time?: string[];
}

// 列表展示项
export interface ProduceOrderTable extends BaseType {
  bom_id?: number;
  craft_id?: number;
  man_hour?: number;
  plan_count?: number;
  real_count?: number;
  plan_date?: string;
  real_date?: string;
  plan_user?: number;
  real_user?: number;
  created_id?: string;
  updated_id?: string;
  created_by?: CommonType;
  updated_by?: CommonType;
}

// 新增/修改/详情表单参数
export interface ProduceOrderForm extends BaseFormType {
  bom_id?: number;
  craft_id?: number;
  man_hour?: number;
  plan_count?: number;
  real_count?: number;
  plan_date?: string;
  real_date?: string;
  plan_user?: number;
}
