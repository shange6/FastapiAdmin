<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <div class="flex-x-between">
          <div class="flex-x-start">
            <el-button type="info" plain icon="Expand" @click="toggleAllExpansion(true)">
              展开
            </el-button>
            <el-button type="info" plain icon="Fold" @click="toggleAllExpansion(false)">
              收起
            </el-button>
          </div>
          <div class="flex-x-end">
            <el-button
              v-hasPerm="['module_make:blanking:update']"
              type="warning"
              icon="FolderChecked"
              @click="handleBatchSaveCraftRoute"
            >
              提交
            </el-button>
            <el-button type="primary" icon="Collection" @click="handleOpenProjectDrawer">
              项目
            </el-button>
          </div>
        </div>
      </template>

      <!-- 表格区域：制造流程主列表 (树形结构) -->
      <el-table
        ref="tableRef"
        v-loading="loading"
        :data="pageTableData"
        row-key="_tree_id"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        highlight-current-row
        class="data-table__content"
        border
        stripe
        @selection-change="handleSelectionChange"
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column type="selection" min-width="40" align="center" />
        <el-table-column
          label="代号"
          prop="code"
          min-width="260"
          header-align="center"
          show-overflow-tooltip
          fixed="left"
        />
        <el-table-column
          label="名称"
          prop="spec"
          min-width="160"
          header-align="center"
          show-overflow-tooltip
          fixed="left"
        />
        <el-table-column
          label="数量"
          prop="count"
          min-width="60"
          align="center"
          header-align="center"
        />
        <el-table-column
          label="材质"
          prop="material"
          min-width="100"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="单重"
          prop="unit_mass"
          min-width="70"
          align="center"
          header-align="center"
        />
        <el-table-column
          label="总重"
          prop="total_mass"
          min-width="70"
          align="center"
          header-align="center"
        />
        <el-table-column
          label="备注"
          prop="remark"
          min-width="100"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          fixed="right"
          label="操作"
          align="center"
          min-width="150"
        >
          <template #default="scope">
            <el-button
              v-hasPerm="['module_make:blanking:detail']"
              type="info"
              link
              icon="document"
              @click="handleOpenDialog('detail', scope.row.id)"
            >
              详情
            </el-button>
            <el-button
              v-hasPerm="['module_make:blanking:update']"
              type="primary"
              link
              icon="Checked"
              @click="handleSubmitFlow(scope.row)"
            >
              提交
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 项目选择抽屉 -->
    <ProjectSelectDrawer 
      v-model="projectDrawerVisible" 
      :show-bom-table="true"
      :show-order-column="true"
      :show_dai="2"
      @select="handleSelectProject" 
    />

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
        <el-descriptions-item label="父代号" :span="2">
          {{ detailFormData.parent_code }}
        </el-descriptions-item>
        <el-descriptions-item label="数量" :span="2">
          {{ detailFormData.count }}
        </el-descriptions-item>
        <el-descriptions-item label="根代号" :span="2">
          {{ detailFormData.first_code }}
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
        <el-descriptions-item label="当前工艺序号" :span="2">
          {{ detailFormData.current_sort }}
        </el-descriptions-item>
        <el-descriptions-item label="当前工艺名称" :span="2">
          {{ detailFormData.current_craft_id ? (craftMap.get(Number(detailFormData.current_craft_id)) || detailFormData.current_craft_id) : '' }}
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
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "ProduceMake",
  inheritAttrs: false,
});

import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Checked,
} from "@element-plus/icons-vue";
import ProduceMakeAPI, {
  ProduceMakeTable,
  ProduceMakeForm,
} from "@/api/module_make/blanking";
import DataBomAPI, { DataBomTable, DataBomPageQuery } from "@/api/module_data/bom";
import ProduceCraftAPI, { ProduceCraftTable } from "@/api/module_produce/craft";
import BomSearch from "@/views/module_data/BomSearch.vue";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import { convertToTree } from "@/views/module_data/utils";
import { useUserStore } from "@/store/modules/user.store";

const userStore = useUserStore();
const tableRef = ref();
const selectIds = ref<number[]>([]);
const selectionRows = ref<any[]>([]);
const loading = ref(false);
const isExpand = ref(false);

// 扩展 DataBomTable 类型，包含制造流程主相关字段
interface DataBomWithMake extends DataBomTable {
  order_no?: string;
  project_code?: string;
  current_sort?: number;
  current_craft_id?: number;
  status?: string;
  description?: string;
  make_id?: number; // 关联 produce_make 的 ID
}

// 分页表单
const pageTableData = ref<DataBomWithMake[]>([]);

// 项目选择相关
const projectDrawerVisible = ref(false);

// 查询参数 (复用 BOM 查询参数)
const queryFormData = reactive<DataBomPageQuery>({
  page_no: 1,
  page_size: 10,
});

// 全量缓存
const allBoms = ref<DataBomWithMake[]>([]);
const allProduceMakes = ref<ProduceMakeTable[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);

// 工艺字典映射
const craftMap = ref<Map<number, string>>(new Map());
const blankingCraftId = ref<number | undefined>(undefined);

async function loadCraftMap() {
  try {
    const res = await ProduceCraftAPI.getAllProduceCraft();
    const map = new Map();
    res.data.data?.forEach((item: ProduceCraftTable) => {
      if (item.id) {
        map.set(item.id, item.name);
        if (item.name === "铆焊") {
          blankingCraftId.value = item.id;
        }
      }
    });
    craftMap.value = map;
  } catch (error) {
    console.error("Failed to load craft map:", error);
  }
}

function syncProduceMakeToFullList() {
  if (!allBoms.value || allBoms.value.length === 0) return;
  
  // 建立 bom_id 映射 Map，用于快速查找
  const makeMap = new Map(allProduceMakes.value.map(m => [m.bom_id ? Number(m.bom_id) : 0, m]));

  // 直接在扁平列表上同步数据
  allBoms.value.forEach((node) => {
    const make = makeMap.get(Number(node.id));
    if (make) {
      node.order_no = make.order_no;
      node.project_code = make.project_code;
      node.current_sort = make.current_sort ? Number(make.current_sort) : undefined;
      node.current_craft_id = make.current_craft_id ? Number(make.current_craft_id) : undefined;
      node.status = make.status;
      node.description = make.description;
      node.make_id = Number(make.id);
      // 同步审计字段
      node.created_by = make.created_by;
      node.updated_by = make.updated_by;
      node.created_time = make.created_time;
      node.updated_time = make.updated_time;
    } else {
      node.order_no = undefined;
      node.project_code = undefined;
      node.current_sort = undefined;
      node.current_craft_id = undefined;
      node.status = undefined;
      node.description = undefined;
      node.make_id = undefined;
      // 如果没有制造流程记录，审计字段保持 BOM 的（虽然 listRecursiveBoms 目前没返回这些）
    }
  });
}

async function ensureProduceMakesLoaded() {
  // 获取当前所有 BOM ID
  const bomIds = allBoms.value.map(b => Number(b.id)).filter(id => id > 0);
  if (bomIds.length === 0) return;
  
  // 获取当前项目代号
  const projectCode = selectedRootBomCode.value ? allBoms.value[0]?.project_code : queryFormData.parent_code;
  
  try {
    const res = await ProduceMakeAPI.listProduceMake({ 
      project_code: projectCode
    });
    allProduceMakes.value = res.data?.data?.items || [];
  } catch (error) {
    console.error("Failed to load produce makes:", error);
    allProduceMakes.value = [];
  }
}

async function loadingData() {
  if (!selectedRootBomCode.value && !queryFormData.parent_code) {
    pageTableData.value = [];
    return;
  }

  ElMessage.info("正在更新数据... ...请稍后");
  loading.value = true;
  try {
    // 加载制造流程主数据
    await ensureProduceMakesLoaded();
    
    // 1. 同步制造流程主到扁平列表 (源数据同步)
    syncProduceMakeToFullList();

    // 2. 直接转换为树形结构
    const { tree } = convertToTree(
      allBoms.value.filter(node => node.current_craft_id === blankingCraftId.value), 
      selectedRootBomCode.value ? undefined : queryFormData.parent_code, 
      selectedRootBomCode.value
    );

    // 3. 渲染页面
    pageTableData.value = tree;
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

// 查询
async function handleQuery() {
  loadingData();
}

// 展开/收起所有行
function toggleAllExpansion(expanded: boolean) {
  isExpand.value = expanded;
  const toggle = (nodes: any[]) => {
    nodes.forEach((node: any) => {
      tableRef.value?.toggleRowExpansion(node, expanded);
      if (node.children) {
        toggle(node.children);
      }
    });
  };
  toggle(pageTableData.value);
}

// 重置查询
function handleResetQuery() {
  queryFormData.code = undefined;
  queryFormData.spec = undefined;
  queryFormData.material = undefined;
  queryFormData.remark = undefined;
  handleQuery();
}

// 打开项目选择抽屉
async function handleOpenProjectDrawer() {
  projectDrawerVisible.value = true;
}

// 选择项目
function handleSelectProject(project: any) {
  if (project.recursive_data && project.root_bom_code) {
    queryFormData.parent_code = project.code;
    projectDrawerVisible.value = false;
    selectedRootBomCode.value = project.root_bom_code;
    allBoms.value = project.recursive_data;
    handleQuery();
  }
}

// 弹窗状态
const dialogVisible = reactive({
  title: "",
  visible: false,
  type: "update" as "update" | "detail",
});

// 编辑表单 (使用本地临时类型以配合 el-input-number)
const formData = reactive({
  id: undefined as number | undefined,
  bom_id: undefined as string | undefined,
  order_no: undefined as string | undefined,
  project_code: undefined as string | undefined,
  current_sort: undefined as number | undefined,
  current_craft_id: undefined as number | undefined,
  status: undefined as string | undefined,
  description: undefined as string | undefined,
  code: undefined as string | undefined,
  spec: undefined as string | undefined,
});

// 详情表单
const detailFormData = ref<DataBomWithMake>({});

// 验证规则
const rules = reactive({
  order_no: [{ required: true, message: "请输入单号", trigger: "blur" }],
  status: [{ required: true, message: "请选择状态", trigger: "change" }],
});

// 打开弹窗
async function handleOpenDialog(type: "update" | "detail", id?: number) {
  dialogVisible.type = type;
  dialogVisible.title = type === "update" ? "编辑制造流程" : "详情";
  
  // 从 pageTableData 找到对应的行
  const row = findNodeById(pageTableData.value, id);
  if (!row) return;

  if (type === "detail") {
    // 1. 先用本地数据快速展示
    detailFormData.value = { ...row };
    
    // 2. 如果有 make_id，从后端拉取完整的制造流程详情（包含审计信息）
    if (row.make_id) {
      try {
        const res = await ProduceMakeAPI.detailProduceMake(row.make_id);
        Object.assign(detailFormData.value, res.data.data);
      } catch (error) {
        console.error("Failed to load produce make detail:", error);
      }
    } else if (row.id) {
      // 3. 如果没有 make_id，从后端拉取完整的 BOM 详情（包含审计信息）
      try {
        const res = await DataBomAPI.detailDataBom(row.id);
        Object.assign(detailFormData.value, res.data.data);
      } catch (error) {
        console.error("Failed to load bom detail:", error);
      }
    }
  } else {
    // 初始化 formData
    Object.assign(formData, {
      id: row.make_id,
      bom_id: String(row.id),
      order_no: row.order_no,
      project_code: row.project_code,
      current_sort: row.current_sort,
      current_craft_id: row.current_craft_id,
      status: row.status || "0",
      description: row.description,
      code: row.code,
      spec: row.spec,
    });
  }
  dialogVisible.visible = true;
}

function findNodeById(nodes: any[], id?: number): any {
  for (const node of nodes) {
    if (node.id === id) return node;
    if (node.children) {
      const found = findNodeById(node.children, id);
      if (found) return found;
    }
  }
  return null;
}

// 关闭弹窗
function handleCloseDialog() {
  dialogVisible.visible = false;
  Object.assign(formData, {
    id: undefined,
    bom_id: undefined,
    order_no: undefined,
    project_code: undefined,
    current_sort: undefined,
    current_craft_id: undefined,
    status: undefined,
    description: undefined,
    code: undefined,
    spec: undefined,
  });
}

// 提交表单
async function handleSubmit() {
  if (dialogVisible.type === "detail") {
    handleCloseDialog();
    return;
  }

  try {
    // 转换类型以符合 ProduceMakeForm
    const submitData: ProduceMakeForm = {
      bom_id: formData.bom_id,
      order_no: formData.order_no,
      project_code: formData.project_code,
      current_sort: formData.current_sort !== undefined ? String(formData.current_sort) : undefined,
      current_craft_id: formData.current_craft_id !== undefined ? String(formData.current_craft_id) : undefined,
      status: formData.status,
      description: formData.description,
    };

    if (formData.id) {
      await ProduceMakeAPI.updateProduceMake(formData.id, submitData);
      ElMessage.success("修改成功");
    } else {
      await ProduceMakeAPI.createProduceMake(submitData);
      ElMessage.success("创建成功");
    }
    handleCloseDialog();
    handleQuery();
  } catch (error: any) {
    console.error(error);
  }
}

// 状态处理
function getStatusLabel(status?: string) {
  const map: Record<string, string> = {
    "0": "待生产",
    "1": "生产中",
    "2": "已完成",
    "3": "已取消",
    "4": "已暂停",
  };
  return status !== undefined ? map[status] || "未知" : "";
}

function getStatusType(status?: string) {
  const map: Record<string, string> = {
    "0": "info",
    "1": "primary",
    "2": "success",
    "3": "danger",
    "4": "warning",
  };
  return status !== undefined ? (map[status] as any) || "" : "";
}

// 行复选框选中项变化
async function handleSelectionChange(selection: any) {
  selectIds.value = selection.map((item: any) => item.id);
  selectionRows.value = selection;
}

// 提交制造流程执行记录
async function handleSubmitFlow(row: DataBomWithMake) {
  if (!row.make_id || !row.id) {
    ElMessage.warning("缺少制造主信息或BOM信息，无法提交");
    return;
  }

  try {
    await ElMessageBox.confirm(`确定要提交【${row.spec}】的当前工序执行记录吗？`, "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    const flowData: any = {
      make_id: row.make_id,
      bom_id: Number(row.id),
      user_id: userStore.basicInfo.id,
      sort: row.current_sort,
      craft_id: row.current_craft_id,
      end_time: new Date().toISOString(),
    };

    await ProduceMakeAPI.submitProduceMakeFlow(flowData);
    ElMessage.success("提交成功");
    handleQuery(); // 刷新数据
  } catch (error: any) {
    if (error !== "cancel") {
      console.error("Submit flow error:", error);
    }
  }
}

// 批量保存工艺路线 (执行记录提交)
async function handleBatchSaveCraftRoute() {
  if (selectionRows.value.length === 0) {
    ElMessage.warning("请选择要提交的行");
    return;
  }

  // 检查是否所有选中的行都有 make_id 和 id
  const invalidRows = selectionRows.value.filter(row => !row.make_id || !row.id);
  if (invalidRows.length > 0) {
    ElMessage.warning(`选中的行中有 ${invalidRows.length} 条数据缺失制造主信息，无法批量提交`);
    return;
  }

  try {
    await ElMessageBox.confirm(`确定要批量提交选中的 ${selectionRows.value.length} 条记录吗？`, "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    loading.value = true;
    let successCount = 0;
    let failCount = 0;

    for (const row of selectionRows.value) {
      try {
        const flowData: any = {
          make_id: row.make_id,
          bom_id: Number(row.id),
          user_id: userStore.basicInfo.id,
          sort: row.current_sort,
          craft_id: row.current_craft_id,
          end_time: new Date().toISOString(),
        };
        await ProduceMakeAPI.submitProduceMakeFlow(flowData);
        successCount++;
      } catch (error: any) {
        console.error(`Row ${row.code} submit error:`, error);
        failCount++;
      }
    }

    if (failCount === 0) {
      ElMessage.success(`成功提交 ${successCount} 条记录`);
    } else {
      ElMessage.warning(`提交完成：成功 ${successCount} 条，失败 ${failCount} 条`);
    }
    handleQuery(); // 刷新数据
  } catch (error: any) {
    if (error !== "cancel") {
      console.error("Batch submit error:", error);
    }
  } finally {
    loading.value = false;
  }
}

onMounted(async () => {
  await loadCraftMap();
  pageTableData.value = [];
});
</script>

<style lang="scss" scoped></style>
