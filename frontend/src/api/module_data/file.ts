import request from "@/utils/request";

const API_PATH = "/data/file";

export const FileAPI = {
  /**
   * 上传文件
   * @param formData 文件数据
   */
  uploadFile(formData: FormData) {
    return request<ApiResponse<FileUploadSchema>>({
      url: `${API_PATH}/upload`,
      method: "post",
      data: formData,
      headers: { "Content-Type": "multipart/form-data" },
    });
  },

  /**
   * 保存解析后的数据
   * @param data 项目及BOM数据
   */
  saveData(data: { project: any; bom: any[] }) {
    return request<ApiResponse<any>>({
      url: `${API_PATH}/save_data`,
      method: "post",
      data,
    });
  },
};

export default FileAPI;

/**
 * 资源上传响应模型
 */
export interface FileUploadSchema {
  /** BOM 列表 */
  boms: BomItem[];
  /** 解析日志 */
  log: LogEntry[];
  /** 项目代号 */
  project_code: string;
  /** 项目名称 */
  project_name: string;
  /** 项目编号 */
  project_no: string;
  /** 根节点 */
  first_code: string;
  /** 文件个数 */
  file_count: number;
}

/**
 * BOM 项模型
 */
export interface BomItem {
  /** 序号 */
  seq?: string | number;
  /** 物料编码 */
  code?: string;
  /** 父代号 */
  parent_code?: string;
  /** 物料规格 */
  spec: string;
  /** 数量 */
  count: number;
  /** 材质 */
  material?: string;
  /** 单重 */
  unit_mass?: number;
  /** 总重 */
  total_mass?: number;
  /** 备注 */
  remark?: string;
  /** x坐标 */
  // x?: number;
  /** y坐标 */
  // y?: number;
  [key: string]: any;
}

/**
 * 解析日志模型
 */
export interface LogEntry {
  /** 状态 */
  status: string;
  /** 消息 */
  msg: string;
  /** 关联的 BOM 数据 */
  bom?: Partial<BomItem>;
}
