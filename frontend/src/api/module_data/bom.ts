import request from "@/utils/request";

const API_PATH = "/data/bom";

const DataBomAPI = {
  // 列表查询
  listDataBom(query: DataBomQuery) {
    return request<ApiResponse<DataBomTable[]>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 查询不需要采购的BOM列表
  listDataBomNoProcure() {
    return request<ApiResponse<DataBomTable[]>>({
      url: `${API_PATH}/list/no-procure`,
      method: "get",
    });
  },

  // 详情查询
  detailDataBom(id: number) {
    return request<ApiResponse<DataBomTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 新增
  createDataBom(body: DataBomForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateDataBom(id: number, body: DataBomForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteDataBom(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 批量启用/停用
  batchDataBom(body: BatchType) {
    return request<ApiResponse>({
      url: `${API_PATH}/available/setting`,
      method: "patch",
      data: body,
    });
  },

  // 导出
  exportDataBom(query: DataBomPageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateDataBom() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importDataBom(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default DataBomAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface DataBomQuery {
  parent_code?: string;
  first_code?: string;
  code?: string;
  spec?: string;
  count?: number;
  material?: string;
  unit_mass?: number;
  total_mass?: number;
  remark?: string;
  status?: string;
  created_time?: string[];
  updated_time?: string[];
  created_id?: number;
  updated_id?: number;
}

export interface DataBomPageQuery extends PageQuery {
  parent_code?: string;
  first_code?: string;
  code?: string;
  spec?: string;
  count?: number;
  material?: string;
  unit_mass?: number;
  total_mass?: number;
  remark?: string;
  status?: string;
  created_time?: string[];
  updated_time?: string[];
  created_id?: number;
  updated_id?: number;
}

// 列表展示项
export interface DataBomTable extends BaseType {
  parent_code?: string;
  first_code?: string;
  code?: string;
  spec?: string;
  count?: number;
  material?: string;
  unit_mass?: number;
  total_mass?: number;
  remark?: string;
  borrow?: boolean;
  procure?: boolean;
  noimage?: boolean;
  figure?: boolean;
  no?: string;
  manhour_details?: { name: string; value: number }[];
  created_id?: string;
  updated_id?: string;
  created_by?: CommonType;
  updated_by?: CommonType;
  children?: DataBomTable[];
}

// 新增/修改/详情表单参数
export interface DataBomForm extends BaseFormType {
  parent_code?: string;
  first_code?: string;
  code?: string;
  spec?: string;
  count?: number;
  material?: string;
  unit_mass?: number;
  total_mass?: number;
  remark?: string;
}
