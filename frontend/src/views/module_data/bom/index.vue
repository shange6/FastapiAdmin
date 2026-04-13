<!-- BOM清单 -->
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
            <el-form-item label="代号" prop="code">
              <el-input
                v-model="queryFormData.code"
                placeholder="请输入代号"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <el-form-item label="名称" prop="spec">
              <el-input
                v-model="queryFormData.spec"
                placeholder="请输入名称"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <el-form-item label="材质" prop="material">
              <el-input
                v-model="queryFormData.material"
                placeholder="请输入材质"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <el-form-item label="备注" prop="remark">
              <el-input
                v-model="queryFormData.remark"
                placeholder="请输入备注"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <!-- 查询、重置、展开/收起按钮 -->
            <el-form-item>
              <el-button
                v-hasPerm="['module_data:bom:query']"
                icon="refresh"
                @click="handleResetQuery"
              >
                重置
              </el-button>
              <div>&nbsp;&nbsp;</div>
              <el-button type="info" plain icon="Expand" @click="toggleAllExpansion(true)">
                展开
              </el-button>
              <el-button type="info" plain icon="Fold" @click="toggleAllExpansion(false)">
                收起
              </el-button>
              <el-button type="primary" icon="Collection" @click="handleOpenProjectDrawer">
                项目
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </template>

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
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column
          label="代号"
          prop="code"
          min-width="260"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="名称"
          prop="spec"
          min-width="160"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="数量"
          prop="count"
          min-width="50"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="材质"
          prop="material"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="单重"
          prop="unit_mass"
          min-width="60"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="总重"
          prop="total_mass"
          min-width="70"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="备注"
          prop="remark"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          fixed="right"
          label="操作"
          align="center"
          min-width="60"
        >
          <template #default="scope">
            <el-button
              v-hasPerm="['module_data:bom:detail']"
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
    </el-card>

    <!-- 弹窗区域 -->
    <el-dialog
      v-model="dialogVisible.visible"
      :title="dialogVisible.title"
      @close="handleCloseDialog"
    >
      <!-- 详情 -->
      <el-descriptions :column="4" border>
        <el-descriptions-item label="主键ID" :span="2">
          {{ detailFormData.id }}
        </el-descriptions-item>
        <el-descriptions-item label="根代号" :span="2">
          {{ detailFormData.first_code }}
        </el-descriptions-item>
        <el-descriptions-item label="数量" :span="2">
          {{ detailFormData.count }}
        </el-descriptions-item>
        <el-descriptions-item label="父代号" :span="2">
          {{ detailFormData.parent_code }}
        </el-descriptions-item>
        <el-descriptions-item label="单重" :span="2">
          {{ detailFormData.unit_mass }}
        </el-descriptions-item>
        <el-descriptions-item label="代号" :span="2">
          {{ detailFormData.code }}
        </el-descriptions-item>
        <el-descriptions-item label="总重" :span="2">
          {{ detailFormData.total_mass }}
        </el-descriptions-item>
        <el-descriptions-item label="名称" :span="2">
          {{ detailFormData.spec }}
        </el-descriptions-item>
        <el-descriptions-item label="状态" :span="2">
          <el-tag :type="detailFormData.status == '0' ? 'success' : 'danger'">
            {{ detailFormData.status == "0" ? "启用" : "停用" }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="材质" :span="2">
          {{ detailFormData.material }}
        </el-descriptions-item>
        <el-descriptions-item label="描述" :span="2">
          {{ detailFormData.description }}
        </el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">
          {{ detailFormData.remark }}
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

    <!-- 项目选择抽屉 -->
    <ProjectSelectDrawer v-model="projectDrawerVisible" @select="handleSelectProject" />

    <!-- 导入弹窗 -->
    <ImportModal
      v-model="importDialogVisible"
      :content-config="curdContentConfig"
      :loading="uploadLoading"
      @upload="handleUpload"
    />
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "DataBom",
  inheritAttrs: false,
});

import { ref, reactive, onMounted, watch } from "vue";
import { useDebounceFn } from "@vueuse/core";
import { ResultEnum } from "@/enums/api/result.enum";
import type { IContentConfig } from "@/components/CURD/types";
import ImportModal from "@/components/CURD/ImportModal.vue";
import DataBomAPI, { DataBomQuery, DataBomTable } from "@/api/module_data/bom";
import { DataProjectTable } from "@/api/module_data/project";
import ProjectSelectDrawer from "../ProjectSelectDrawer.vue";
import { convertToTree } from "../utils";

const tableRef = ref();
const queryFormRef = ref();
const loading = ref(false);

// 项目选择相关
const projectDrawerVisible = ref(false);
const currentProjectCode = ref<string>(); // 当前选中的项目代号

// 打开项目选择抽屉
async function handleOpenProjectDrawer() {
  projectDrawerVisible.value = true;
}

// 选择项目
async function handleSelectProject(project: DataProjectTable) {
  currentProjectCode.value = project.code;
  projectDrawerVisible.value = false;

  // 获取该项目下的所有后代BOM (按 parent_code 递归获取)
  loading.value = true;
  try {
    const response = await DataBomAPI.listDataBom({
      parent_code: project.code,
      recursive: true,
    });
    allBoms.value = response.data.data || [];
    handleQuery();
  } catch (error) {
    console.error("Fetch BOMs for project error:", error);
  } finally {
    loading.value = false;
  }
}

// 分页表单
const pageTableData = ref<DataBomTable[]>([]);
const allBoms = ref<DataBomTable[]>([]); // 存储全量原始数据，用于树形搜索

// 详情表单
const detailFormData = ref<DataBomTable>({});

// 导入/导出配置
const curdContentConfig = {
  permPrefix: "module_data:bom",
  cols: [
    { prop: "parent_code", label: "父代号" },
    { prop: "first_code", label: "根代号" },
    { prop: "code", label: "代号" },
    { prop: "spec", label: "名称" },
    { prop: "count", label: "数量" },
    { prop: "material", label: "材质" },
    { prop: "unit_mass", label: "单重" },
    { prop: "total_mass", label: "总重" },
    { prop: "remark", label: "备注" },
    { prop: "status", label: "是否启用(0:启用 1:禁用)" },
    { prop: "description", label: "备注/描述" },
    { prop: "created_time", label: "创建时间" },
    { prop: "updated_time", label: "更新时间" },
    { prop: "created_id", label: "创建人ID" },
    { prop: "updated_id", label: "更新人ID" },
  ] as any,
  importTemplate: () => DataBomAPI.downloadTemplateDataBom(),
  exportsAction: async (params: any) => {
    const query: any = { ...params };
    query.status = "0";
    const res = await DataBomAPI.listDataBom(query);
    return res.data?.data || [];
  },
} as unknown as IContentConfig;

const queryFormData = reactive<DataBomQuery>({
  parent_code: undefined,
  first_code: undefined,
  code: undefined,
  spec: undefined,
  count: undefined,
  material: undefined,
  unit_mass: undefined,
  total_mass: undefined,
  remark: undefined,
  status: undefined,
  recursive: false,
});

// 弹窗状态
const dialogVisible = reactive({
  title: "",
  visible: false,
});

// 导入弹窗显示状态
const importDialogVisible = ref(false);
const uploadLoading = ref(false);

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

// 加载/过滤表格数据
async function loadingData() {
  const codeSearch = queryFormData.code?.toLowerCase() || "";
  const specSearch = queryFormData.spec?.toLowerCase() || "";
  const materialSearch = queryFormData.material?.toLowerCase() || "";
  const remarkSearch = queryFormData.remark?.toLowerCase() || "";

  loading.value = true;
  try {
    // 3. 本地过滤逻辑
    const filtered = allBoms.value.filter((item) => {
      const matchCode = !codeSearch || item.code?.toLowerCase().includes(codeSearch);
      const matchSpec = !specSearch || item.spec?.toLowerCase().includes(specSearch);
      const matchMaterial =
        !materialSearch || item.material?.toLowerCase().includes(materialSearch);
      const matchRemark = !remarkSearch || item.remark?.toLowerCase().includes(remarkSearch);
      return matchCode && matchSpec && matchMaterial && matchRemark;
    });

    // 4. 为了保证树形结构的完整性，需要补充匹配节点的父节点
    const matchedCodes = new Set(filtered.map((item) => item.code));
    const finalBoms = new Set(filtered);

    // 递归寻找所有匹配项的父节点
    const addParents = (bom: any) => {
      if (bom.parent_code) {
        const parent = allBoms.value.find((p) => p.code === bom.parent_code);
        if (parent && !matchedCodes.has(parent.code)) {
          finalBoms.add(parent);
          matchedCodes.add(parent.code);
          addParents(parent);
        }
      }
    };

    filtered.forEach(addParents);

    // 5. 重新转换为树形结构展示
    const { tree } = convertToTree(Array.from(finalBoms), currentProjectCode.value);
    pageTableData.value = tree;
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

// 防抖查询
const debouncedSearch = useDebounceFn(() => {
  handleQuery();
}, 1000);

// 监听搜索参数变化
watch(
  () => [
    queryFormData.code,
    queryFormData.spec,
    queryFormData.material,
    queryFormData.remark,
    queryFormData.status,
  ],
  () => {
    debouncedSearch();
  }
);

// 查询
async function handleQuery() {
  loadingData();
}

// 重置查询
async function handleResetQuery() {
  queryFormRef.value.resetFields();
  // 不再清空 allBoms 缓存，利用本地数据恢复表格，减少后端请求
  loadingData();
}

// 关闭弹窗
async function handleCloseDialog() {
  dialogVisible.visible = false;
}

// 打开弹窗
async function handleOpenDialog(id: number) {
  if (id) {
    const response = await DataBomAPI.detailDataBom(id);
    dialogVisible.title = "详情";
    Object.assign(detailFormData.value, response.data.data);
    dialogVisible.visible = true;
  }
}

// 处理上传
const handleUpload = async (formData: FormData) => {
  try {
    uploadLoading.value = true;
    const response = await DataBomAPI.importDataBom(formData);
    if (response.data.code === ResultEnum.SUCCESS) {
      importDialogVisible.value = false;
      await handleResetQuery();
    }
  } catch (error: any) {
    console.error(error);
  } finally {
    uploadLoading.value = false;
  }
};

onMounted(async () => {
  // loadingData();
});
</script>

<style lang="scss" scoped></style>
