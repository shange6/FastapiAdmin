<!-- 项目信息 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <!-- 搜索区域 -->
        <div class="search-container">
          <el-form
            ref="queryFormRef"
            :model="queryFormData"
            label-suffix=":"
            :inline="true"
            @submit.prevent="handleQuery"
          >
            <el-form-item label="项目编码" prop="code">
              <el-input
                v-model="queryFormData.code"
                placeholder="输入项目编码"
                clearable
                style="width: 110px"
              />
            </el-form-item>
            <el-form-item label="项目名称" prop="name">
              <el-input
                v-model="queryFormData.name"
                placeholder="输入项目名称"
                clearable
                style="width: 110px"
              />
            </el-form-item>
            <el-form-item label="项目编号" prop="no">
              <el-input
                v-model="queryFormData.no"
                placeholder="输入项目编号"
                clearable
                style="width: 110px"
              />
            </el-form-item>
            <!-- 查询、重置、展开/收起按钮 -->
            <el-form-item>
              <el-button
                icon="refresh"
                @click="handleResetQuery"
              >
                重置
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </template>

      <!-- 表格区域：系统配置列表 -->
      <el-table
        v-loading="loading"
        :data="pageTableData"
        highlight-current-row
        class="data-table__content"
        border
        stripe
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column
          label="项目编码"
          prop="code"
          min-width="150"
          show-overflow-tooltip
          header-align="center"
          align="center"
        />
        <el-table-column
          label="项目名称"
          prop="name"
          min-width="200"
          show-overflow-tooltip
          header-align="center"
          align="center"
        />
        <el-table-column
          label="项目编号"
          prop="no"
          min-width="100"
          show-overflow-tooltip
          header-align="center"
          align="center"
        />
        <el-table-column
          label="状态"
          prop="status"
          min-width="55"
          align="center"
          header-align="center"
          show-overflow-tooltip
        >
          <template #default="scope">
            <el-tag :type="scope.row.status == '0' ? 'success' : 'info'">
              {{ scope.row.status == "0" ? "启用" : "停用" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          fixed="right"
          label="操作"
          align="center"
          min-width="100"
        >
          <template #default="scope">
            <el-button
              type="info"
              size="small"
              link
              icon="document"
              @click="handleOpenDialog(scope.row.id)"
            >
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页区域 -->
      <template #footer>
        <pagination
          v-model:total="total"
          v-model:page="queryFormData.page_no"
          v-model:limit="queryFormData.page_size"
          @pagination="loadingData"
        />
      </template>
    </el-card>

    <!-- 弹窗区域 -->
    <el-dialog
      v-model="dialogVisible.visible"
      :title="dialogVisible.title"
      @close="handleCloseDialog"
    >
      <!-- 详情 -->
      <el-descriptions :column="4" border>
        <el-descriptions-item label="项目编码" :span="2" :label-width="120">
          {{ detailFormData.code }}
        </el-descriptions-item>
        <el-descriptions-item label="项目名称" :span="2" :label-width="120">
          {{ detailFormData.name }}
        </el-descriptions-item>
        <el-descriptions-item label="项目编号" :span="2" :label-width="120">
          {{ detailFormData.no }}
        </el-descriptions-item>
        <el-descriptions-item label="UUID" :span="2" :label-width="120">
          {{ detailFormData.uuid }}
        </el-descriptions-item>
        <el-descriptions-item label="状态" :span="2">
          <el-tag :type="detailFormData.status == '0' ? 'success' : 'danger'">
            {{ detailFormData.status == "0" ? "启用" : "停用" }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="描述" :span="2">
          {{ detailFormData.description }}
        </el-descriptions-item>
        <el-descriptions-item label="创建人" :span="2">
          {{ detailFormData.created_by?.name }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间" :span="2">
          {{ detailFormData.created_time }}
        </el-descriptions-item>
        <el-descriptions-item label="更新人" :span="2">
          {{ detailFormData.updated_by?.name }}
        </el-descriptions-item>
        <el-descriptions-item label="更新时间" :span="2">
          {{ detailFormData.updated_time }}
        </el-descriptions-item>
      </el-descriptions>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="handleCloseDialog">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "DataProject",
  inheritAttrs: false,
});

import { ref, reactive, onMounted, watch } from "vue";
import DataProjectAPI, {
  DataProjectPageQuery,
  DataProjectTable,
} from "@/api/module_data/project";

const queryFormRef = ref();
const total = ref(0);
const loading = ref(false);

// 分页表单
const pageTableData = ref<DataProjectTable[]>([]);
const allProjects = ref<DataProjectTable[]>([]); // 存储全量原始数据用于本地过滤

// 详情表单
const detailFormData = ref<DataProjectTable>({});

// 分页查询参数
const queryFormData = reactive<DataProjectPageQuery>({
  page_no: 1,
  page_size: 10,
  code: undefined,
  name: undefined,
  no: undefined,
});

// 弹窗状态
const dialogVisible = reactive({
  title: "",
  visible: false,
});

// 加载表格数据
async function loadingData() {
  loading.value = true;
  try {
    // 1. 如果缓存为空，则从后端拉取全量数据（不分页新接口）
    if (allProjects.value.length === 0) {
      const response = await DataProjectAPI.getAllDataProject();
      allProjects.value = response.data.data || [];
    }

    // 2. 本地过滤逻辑
    const codeSearch = queryFormData.code?.toLowerCase() || "";
    const nameSearch = queryFormData.name?.toLowerCase() || "";
    const noSearch = queryFormData.no?.toLowerCase() || "";

    const filtered = allProjects.value.filter((item) => {
      const matchCode = !codeSearch || item.code?.toLowerCase().includes(codeSearch);
      const matchName = !nameSearch || item.name?.toLowerCase().includes(nameSearch);
      const matchNo = !noSearch || item.no?.toLowerCase().includes(noSearch);
      return matchCode && matchName && matchNo;
    });

    // 3. 处理本地分页
    total.value = filtered.length;
    const start = (queryFormData.page_no - 1) * queryFormData.page_size;
    const end = start + queryFormData.page_size;
    pageTableData.value = filtered.slice(start, end);
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

// 查询（重置页码后获取数据）
async function handleQuery() {
  queryFormData.page_no = 1;
  loadingData();
}

let autoQueryTimer: number | undefined;
function triggerAutoQuery() {
  if (autoQueryTimer) {
    window.clearTimeout(autoQueryTimer);
  }
  autoQueryTimer = window.setTimeout(() => {
    handleQuery();
  }, 300);
}

watch(
  () => [queryFormData.code, queryFormData.name, queryFormData.no],
  () => {
    triggerAutoQuery();
  }
);

// 重置查询
async function handleResetQuery() {
  queryFormRef.value.resetFields();
  queryFormData.page_no = 1;
  loadingData();
}

// 关闭弹窗
async function handleCloseDialog() {
  dialogVisible.visible = false;
}

// 打开弹窗
async function handleOpenDialog(id: number) {
  if (id) {
    const response = await DataProjectAPI.detailDataProject(id);
    dialogVisible.title = "详情";
    Object.assign(detailFormData.value, response.data.data);
    dialogVisible.visible = true;
  }
}

onMounted(async () => {
  loadingData();
});
</script>

<style lang="scss" scoped></style>
