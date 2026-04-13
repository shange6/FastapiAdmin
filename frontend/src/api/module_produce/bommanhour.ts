import request from "@/utils/request";

const API_PATH = "/produce/bommanhour";

const ProduceBomManhourAPI = {
  // 列表查询
  listProduceBomManhour(query: ProduceBomManhourPageQuery) {
    return request<ApiResponse<PageResult<ProduceBomManhourTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 获取全部（不分页）
  getAllProduceBomManhour(query: ProduceBomManhourQuery) {
    return request<ApiResponse<ProduceBomManhourTable[]>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 详情查询
  detailProduceBomManhour(id: number) {
    return request<ApiResponse<ProduceBomManhourTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 新增
  createProduceBomManhour(body: ProduceBomManhourForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateProduceBomManhour(id: number, body: ProduceBomManhourForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 批量插入或更新（忽略工时为0的数据）
  upsertBatchProduceBomManhour(body: { items: ProduceBomManhourUpsertItem[] }) {
    return request<ApiResponse>({
      url: `${API_PATH}/upsert/batch`,
      method: "post",
      data: body,
    });
  },

  // 批量查询BOM工时汇总
  summaryBatchProduceBomManhour(body: { bom_ids: number[]; recursive?: boolean }) {
    return request<
      ApiResponse<Record<string, { craft_id: number; manhour: number; craft_name: string }[]>>
    >({
      url: `${API_PATH}/summary/batch`,
      method: "post",
      data: body,
    });
  },

  // 批量查询BOM工时（按工艺汇总）
  summaryCraftBatchProduceBomManhour(body: { bom_ids: number[] }) {
    return request<ApiResponse<Record<string, Record<string, number>>>>({
      url: `${API_PATH}/summary/craft/batch`,
      method: "post",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceBomManhour(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchProduceBomManhour(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportProduceBomManhour(query: ProduceBomManhourPageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceBomManhour() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceBomManhour(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default ProduceBomManhourAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数（不带分页）
export interface ProduceBomManhourQuery {
  bom_id?: string;
  craft_id?: string;
  manhour?: string;
  created_time?: string[];
  updated_time?: string[];
}

// 列表查询参数
export interface ProduceBomManhourPageQuery extends PageQuery {
  bom_id?: string;
  craft_id?: string;
  manhour?: string;
  created_time?: string[];
  updated_time?: string[];
}

// 列表展示项
export interface ProduceBomManhourTable extends BaseType {
  bom_id?: string;
  craft_id?: string;
  manhour?: string;
  created_by?: CommonType;
  updated_by?: CommonType;
}

// 新增/修改/详情表单参数
export interface ProduceBomManhourForm extends BaseFormType {
  bom_id?: string;
  craft_id?: string;
  manhour?: string;
}

export interface ProduceBomManhourUpsertItem {
  bom_id: number;
  craft_id: number;
  manhour: number;
}
