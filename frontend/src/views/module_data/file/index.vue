<!-- BOM清单 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <!-- 搜索区域 -->
        <BomSearch
          v-model="queryFormData"
          :show-project-btn="false"
          @search="handleQuery"
          @reset="handleResetQuery"
          @toggle-expand="toggleAllExpansion"
        >
          <template #extra>
            <el-button
              v-if="allParsedBoms.length > 0"
              v-hasPerm="['module_data:file:create']"
              type="warning"
              :icon="Checked"
              native-type="button"
              @click="handleSaveData"
            >
              保存
            </el-button>
            <el-button
              v-hasPerm="['module_data:file:create']"
              type="success"
              :icon="Plus"
              @click="handleUploadFile"
            >
              上传
            </el-button>
            <el-button
              type="info"
              :icon="Document"
              @click="logDrawerVisible = true"
            >
              日志
            </el-button>
          </template>
        </BomSearch>
      </template>

      <!-- 导入结果展示抽屉 -->
      <el-drawer v-model="logDrawerVisible" title="文件解析日志" direction="rtl" size="50%">
        <div style="margin-bottom: 20px">
          <el-descriptions title="项目信息" :column="4" border>
            <el-descriptions-item label="合同号" :span="1">
              {{ tableSourceData.project_no }}
            </el-descriptions-item>
            <el-descriptions-item label="项目代号" :span="3">
              {{ tableSourceData.project_code }}
            </el-descriptions-item>
            <el-descriptions-item label="文件个数" :span="1">
              {{ tableSourceData.file_count }}
            </el-descriptions-item>
            <el-descriptions-item label="项目名称" :span="3">
              {{ tableSourceData.project_name }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <div class="log-title" style="font-weight: bold; margin-bottom: 10px; font-size: 16px">
          解析详情：
        </div>
        <div
          v-for="(text, index) in tableSourceData?.info"
          :key="index"
          class="text-line"
          style="font-size: 15px; margin-bottom: 8px; padding: 4px; border-bottom: 1px solid #eee"
          v-html="text"
        ></div>
      </el-drawer>

      <!-- 表格区域：系统配置列表 -->
      <el-table
        ref="tableRef"
        v-loading="loading"
        :data="pageTableData"
        row-key="_tree_id"
        highlight-current-row
        class="data-table__content"
        border
        stripe
        @selection-change="handleSelectionChange"
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'selection')?.show"
          type="selection"
          min-width="40"
          align="center"
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'code')?.show"
          label="代号"
          prop="code"
          min-width="200"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'spec')?.show"
          label="名称"
          prop="spec"
          min-width="140"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'count')?.show"
          label="数量"
          prop="count"
          min-width="50"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'material')?.show"
          label="材质"
          prop="material"
          min-width="100"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'unit_mass')?.show"
          label="单重"
          prop="unit_mass"
          min-width="60"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'total_mass')?.show"
          label="总重"
          prop="total_mass"
          min-width="70"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'remark')?.show"
          label="备注"
          prop="remark"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
      </el-table>
    </el-card>

    <!-- 上传对话框 -->
    <el-dialog
      v-model="uploadDialogVisible"
      title="上传文件"
      width="500px"
      :before-close="handleUploadClose"
    >
      <el-upload
        ref="uploadRef"
        :auto-upload="false"
        :multiple="true"
        :file-list="uploadFileList"
        drag
        @change="handleUploadChange"
      >
        <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或
          <em>点击上传</em>
        </div>
        <template #tip>
          <div class="el-upload__tip" style="color: red">
            不支持多文件上传，单个文件不超过100MB，多文件上传，取最后一个文件上传
          </div>
        </template>
      </el-upload>
      <template #footer>
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button
          v-hasPerm="['module_monitor:resource:upload']"
          type="primary"
          :loading="uploading"
          @click="handleUploadConfirm"
        >
          确定上传
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "DataBom",
  inheritAttrs: false,
});

import { ref, reactive, onMounted, watch, nextTick } from "vue";
import { useDebounceFn } from "@vueuse/core";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Plus,
  Document,
  Checked,
} from "@element-plus/icons-vue";
import FileAPI from "@/api/module_data/file";
import { convertToTree, getMatchedBomsWithParents } from "../utils";
import BomSearch from "../BomSearch.vue";

const tableRef = ref();
const selectIds = ref<number[]>([]);
const selectionRows = ref<any[]>([]);
const loading = ref(false);

// 分页表单
const pageTableData = ref<any[]>([]);
const allParsedBoms = ref<any[]>([]); // 存储解析后的扁平原始数据

// 表格列配置
const tableColumns = ref([
  { prop: "selection", label: "选择框", show: true },
  { prop: "code", label: "代号", show: true },
  { prop: "spec", label: "名称", show: true },
  { prop: "count", label: "数量", show: true },
  { prop: "material", label: "材质", show: true },
  { prop: "unit_mass", label: "单重", show: true },
  { prop: "total_mass", label: "总重", show: true },
  { prop: "remark", label: "备注", show: true },
]);

// 分页查询参数
const queryFormData = reactive<any>({
  page_no: 1,
  page_size: 10,
  code: undefined,
  spec: undefined,
  material: undefined,
  remark: undefined,
});

// 上传相关数据
const uploadDialogVisible = ref(false);
const uploadFileList = ref<any[]>([]);
const uploading = ref(false);
// 解析结果
const tableSourceData = ref<any>({
  info: [],
  project_code: "",
  project_name: "",
  project_no: "",
  first_code: "",
  file_count: 0,
});
const logDrawerVisible = ref(false);
// 路径相关数据
const currentPath = ref("/"); // 当前路径的响应式变量
// 打开上传对话框
function handleUploadFile() {
  uploadDialogVisible.value = true;
  uploadFileList.value = [];
}
// 关闭上传对话框
function handleUploadClose() {
  uploadDialogVisible.value = false;
  uploadFileList.value = [];
}
// 上传文件变化处理
function handleUploadChange(_: any, fileList: any[]) {
  uploadFileList.value = fileList;
}
// 确认上传文件
async function handleUploadConfirm() {
  if (uploadFileList.value.length === 0) {
    ElMessage.warning("请选择要上传的文件");
    return;
  }

  try {
    uploading.value = true;
    const formData = new FormData();
    uploadFileList.value.forEach((file: any) => {
      formData.append("file", file.raw);
    });

    // 在根目录时传递空字符串作为target_path，与后端relative_path格式保持一致
    const targetPath = currentPath.value === "/" ? "" : currentPath.value;
    formData.append("target_path", targetPath);

    const res = await FileAPI.uploadFile(formData);
    // console.log(res)

    if (res.data.success) {
      const resultData = res.data.data;
      // 把boms传递给boms表格显示
      const rawBoms = resultData.boms || [];
      allParsedBoms.value = rawBoms; // 保存扁平原始数据，用于本地搜索

      const { tree, errors } = convertToTree(
        rawBoms,
        resultData.project_code,
        resultData.first_code
      );
      pageTableData.value = tree;

      // 把项目信息和log传给文件解析日志显示
      tableSourceData.value.project_code = resultData.project_code || "";
      tableSourceData.value.project_name = resultData.project_name || "";
      tableSourceData.value.project_no = resultData.project_no || "";
      tableSourceData.value.first_code = resultData.first_code || "";
      tableSourceData.value.file_count = resultData.file_count || 0;

      let logs: string[] = [];
      if (resultData.log && Array.isArray(resultData.log)) {
        logs = resultData.log.map((item: any) => {
          return `[${item.status}] <span style="color: red">${item.msg}</span> 
            ${` (${item.bom?.code}, ${item.bom?.spec}, ${item.bom?.remark})`}`;
        });
      }

      // 合并后端日志和前端结构校验错误
      tableSourceData.value.info = [...logs, ...errors];

      if (tableSourceData.value.info.length === 0) {
        tableSourceData.value.info = ["解析完成，无日志记录"];
      }
      logDrawerVisible.value = true; // 显示文件解析日志窗口
    }

    uploadDialogVisible.value = false;
  } catch (error: any) {
    console.error("Upload error:", error);
  } finally {
    uploading.value = false;
  }
}

// 保存解析后的数据到数据库
async function handleSaveData() {
  if (allParsedBoms.value.length === 0) {
    ElMessage.warning("没有可保存的数据");
    return;
  }

  // 如果有解析日志（非空占位符），说明存在解析错误或警告，提示用户检查
  const hasActualLogs = tableSourceData.value.info.length > 0 && 
                        tableSourceData.value.info[0] !== "解析完成，无日志记录" &&
                        !tableSourceData.value.info[0].includes("[保存成功]");

  if (hasActualLogs) {
    ElMessage.error("文件解析存在异常，请查看日志并修正后再试");
    logDrawerVisible.value = true;
    return;
  }

  try {
    await ElMessageBox.confirm("确定要将当前解析出的数据保存到数据库吗？", "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    loading.value = true;
    const payload = {
      project: {
        name: tableSourceData.value.project_name,
        code: tableSourceData.value.project_code,
        no: tableSourceData.value.project_no,
      },
      bom: allParsedBoms.value,
    };

    const res = await FileAPI.saveData(payload);
    // 如果没有抛出异常，说明 res.data.code === ResultEnum.SUCCESS
    const resultData = res.data.data;

    // 1. 更新日志列表
    const saveLogHeader = `[保存成功] <span style="color: green; font-weight: bold;">数据已成功入库 (新增项目: ${resultData.project_added}, 新增BOM: ${resultData.bom_added})</span>`;

    // 强制触发更新，确保响应式
    const newInfo = [saveLogHeader, ...tableSourceData.value.info];
    tableSourceData.value = {
      ...tableSourceData.value,
      info: newInfo,
    };

    // 2. 打开抽屉并提示
    logDrawerVisible.value = true;
    ElMessage.success(`保存成功！新增BOM: ${resultData.bom_added} 条`);

    // 3. 保存成功后清空解析状态
    allParsedBoms.value = [];
    pageTableData.value = [];
  } catch (error: any) {
    if (error !== "cancel") {
      console.error("Save data error:", error);

      // 尝试从 error.response（Axios错误）获取数据
      const backendData = error.response?.data?.data;
      const duplicateCount = backendData?.duplicate_count || 0;

      if (duplicateCount > 0) {
        const saveLogHeader = `[保存失败] <span style="color: red; font-weight: bold;">发现 ${duplicateCount} 条重复记录，本次操作已回滚</span>`;
        tableSourceData.value.info.unshift(saveLogHeader, ...backendData.duplicate_logs);
        logDrawerVisible.value = true;
      } else if (error.message && error.message.includes("重复")) {
        // 如果拦截器返回的是纯 Error 对象且消息中包含"重复"，从消息解析数量
        const match = error.message.match(/(\d+)/);
        const count = match ? match[1] : "未知";
        const saveLogHeader = `[保存失败] <span style="color: red; font-weight: bold;">发现 ${count} 条重复记录，本次操作已回滚</span>`;
        tableSourceData.value.info.unshift(saveLogHeader);
        logDrawerVisible.value = true;
      }
    }
  } finally {
    loading.value = false;
  }
}

// 展开/收起所有行
function toggleAllExpansion(expanded: boolean) {
  const toggle = (nodes: any[]) => {
    nodes.forEach((node) => {
      tableRef.value?.toggleRowExpansion(node, expanded);
      if (node.children) {
        toggle(node.children);
      }
    });
  };
  toggle(pageTableData.value);
}

// 加载表格数据
async function loadingData() {
  const codeSearch = queryFormData.code?.toLowerCase() || "";
  const specSearch = queryFormData.spec?.toLowerCase() || "";
  const materialSearch = queryFormData.material?.toLowerCase() || "";
  const remarkSearch = queryFormData.remark?.toLowerCase() || "";

  const isSearching = !!(codeSearch || specSearch || materialSearch || remarkSearch);

  loading.value = true;
  try {
    // 使用工具函数获取匹配项及其父路径
    const matchedList = getMatchedBomsWithParents(
      allParsedBoms.value,
      (item) => {
        const matchCode = !codeSearch || item.code?.toLowerCase().includes(codeSearch);
        const matchSpec = !specSearch || item.spec?.toLowerCase().includes(specSearch);
        const matchMaterial = !materialSearch || item.material?.toLowerCase().includes(materialSearch);
        const matchRemark = !remarkSearch || item.remark?.toLowerCase().includes(remarkSearch);
        return matchCode && matchSpec && matchMaterial && matchRemark;
      },
      tableSourceData.value.project_code
    );

    // 转换为树形结构
    const { tree } = convertToTree(matchedList, tableSourceData.value.project_code);
    pageTableData.value = tree;

    // 搜索时自动展开
    if (isSearching) {
      await nextTick();
      toggleAllExpansion(true);
    }
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

// 防抖查询
const debouncedSearch = useDebounceFn(() => {
  handleQuery();
}, 500);

// 监听搜索参数变化
watch(
  () => [
    queryFormData.code,
    queryFormData.spec,
    queryFormData.material,
    queryFormData.remark,
  ],
  () => {
    debouncedSearch();
  }
);

// 查询（重置页码后获取数据）
async function handleQuery() {
  queryFormData.page_no = 1;
  loadingData();
}

// 重置查询
async function handleResetQuery() {
  queryFormData.code = undefined;
  queryFormData.spec = undefined;
  queryFormData.material = undefined;
  queryFormData.remark = undefined;
  queryFormData.page_no = 1;

  // 如果有解析过的数据，恢复显示全部解析数据，而不是清空
  if (allParsedBoms.value.length > 0) {
    loadingData();
  } else {
    pageTableData.value = [];
  }
}

// 行复选框选中项变化
async function handleSelectionChange(selection: any) {
  selectIds.value = selection.map((item: any) => item.id);
  selectionRows.value = selection;
}

onMounted(async () => {
});
</script>

<style lang="scss" scoped></style>
