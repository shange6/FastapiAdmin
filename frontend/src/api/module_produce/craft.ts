import request from "@/utils/request";

const API_PATH = "/produce/craft";

const ProduceCraftAPI = {
  // 列表查询
  listProduceCraft(query: ProduceCraftPageQuery) {
    return request<ApiResponse<PageResult<ProduceCraftTable[]>>>({
      url: `${API_PATH}/list`,
      method: "get",
      params: query,
    });
  },

  // 获取全部工艺字典（不分页）
  getAllProduceCraft() {
    return request<ApiResponse<ProduceCraftTable[]>>({
      url: `${API_PATH}/list/all`,
      method: "get",
    });
  },

  // 详情查询
  detailProduceCraft(id: number) {
    return request<ApiResponse<ProduceCraftTable>>({
      url: `${API_PATH}/detail/${id}`,
      method: "get",
    });
  },

  // 新增
  createProduceCraft(body: ProduceCraftForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/create`,
      method: "post",
      data: body,
    });
  },

  // 修改（带主键）
  updateProduceCraft(id: number, body: ProduceCraftForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/update/${id}`,
      method: "put",
      data: body,
    });
  },

  // 删除（支持批量）
  deleteProduceCraft(ids: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/delete`,
      method: "delete",
      data: ids,
    });
  },

  // 导出
  exportProduceCraft(query: ProduceCraftPageQuery) {
    return request<Blob>({
      url: `${API_PATH}/export`,
      method: "post",
      data: query,
      responseType: "blob",
    });
  },

  // 下载导入模板
  downloadTemplateProduceCraft() {
    return request<Blob>({
      url: `${API_PATH}/download/template`,
      method: "post",
      responseType: "blob",
    });
  },

  // 导入
  importProduceCraft(body: FormData) {
    return request<ApiResponse>({
      url: `${API_PATH}/import`,
      method: "post",
      data: body,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};

export default ProduceCraftAPI;

// ------------------------------
// TS 类型声明
// ------------------------------

// 列表查询参数
export interface ProduceCraftPageQuery extends PageQuery {
  name?: string;
}

// 列表展示项
export interface ProduceCraftTable {
  id?: number;
  name?: string;
}

// 新增/修改/详情表单参数
export interface ProduceCraftForm {
  id?: number;
  name?: string;
}
