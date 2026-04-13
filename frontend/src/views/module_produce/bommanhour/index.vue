<!-- BOM路线关联 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <!-- <div class="card-header">
          <span>
            BOM工时关联列表
            <el-tooltip content="BOM工时关联列表">
              <QuestionFilled class="w-4 h-4 mx-1" />
            </el-tooltip>
          </span>
        </div> -->

        <!-- 搜索区域 -->
        <div v-show="visible" class="search-container">
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
                @keyup.enter="handleQuery"
              />
            </el-form-item>
            <el-form-item label="名称" prop="spec">
              <el-input
                v-model="queryFormData.spec"
                placeholder="请输入名称"
                clearable
                @keyup.enter="handleQuery"
              />
            </el-form-item>
            <!-- 查询、重置、展开/收起按钮 -->
            <el-form-item>
              <el-button type="primary" :icon="Search" @click="handleQuery">查询</el-button>
              <el-button :icon="Refresh" @click="handleResetQuery">重置</el-button>
              <el-button type="info" plain :icon="Expand" @click="toggleAllExpansion(true)">
                展开
              </el-button>
              <el-button type="info" plain :icon="Fold" @click="toggleAllExpansion(false)">
                收起
              </el-button>
              <el-button type="primary" :icon="Collection" @click="handleOpenProjectDrawer">
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
          min-width="280"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'spec')?.show"
          label="名称"
          prop="spec"
          min-width="180"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'count')?.show"
          label="数量"
          prop="count"
          min-width="60"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'material')?.show"
          label="材质"
          prop="material"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'unit_mass')?.show"
          label="单重"
          prop="unit_mass"
          min-width="70"
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
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'craft_route')?.show"
          label="路线"
          prop="route_code"
          min-width="60"
          align="center"
          header-align="center"
          fixed="right"
        >
          <template #default="scope">
            <span>{{ scope.row.route_code }}</span>
          </template>
        </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'manhour')?.show"
          label="工时"
          prop="manhour"
          min-width="60"
          align="center"
          header-align="center"
          fixed="right"
        >
          <template #default="{ row }">
            <el-tooltip placement="top" effect="dark">
              <template #content>
                <div v-if="Array.isArray(row.manhour) && row.manhour.length > 0">
                  <div v-for="(item, index) in row.manhour" :key="index">
                    {{ item.craft_name }}：{{ item.manhour }}
                  </div>
                </div>
                <div v-else>暂无工时</div>
              </template>
              <span style="font-size: 16px; cursor: pointer">
                <span
                  v-if="isManhourComplete(row)"
                  style="color: green"
                >
                  ✔
                </span>
                <span v-else style="color: red">✖</span>
              </span>
            </el-tooltip>
          </template>
        </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'operation')?.show"
          fixed="right"
          label="操作"
          align="center"
          min-width="60"
        >
          <template #default="scope">
            <el-button
              v-hasPerm="['module_produce:bommanhour:update']"
              type="primary"
              link
              @click="handleOpenManhourDialog(scope.row)"
            >
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 项目选择抽屉 -->
    <ProjectSelectDrawer v-model="projectDrawerVisible" @select="handleSelectProject" />

    <el-dialog
      v-model="manhourDialogVisible"
      title="工时"
      width="600px"
      top="5vh"
      @close="handleCloseManhourDialog"
    >
      <el-descriptions v-if="manhourBom" :column="2" border>
        <el-descriptions-item label-align="center" label="代号">
          {{ manhourBom.code }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="数量">
          {{ manhourBom.count }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="名称">
          {{ manhourBom.spec }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="单重">
          {{ manhourBom.unit_mass }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="材质">
          {{ manhourBom.material }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="总重">
          {{ manhourBom.total_mass }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="备注" :span="2">
          {{ manhourBom.remark }}
        </el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">工艺工时</el-divider>
      <el-skeleton v-if="manhourLoading" :rows="6" animated />
      <el-empty v-else-if="manhourSteps.length === 0" description="该路线未配置工艺" />
      <el-form v-else label-position="left" style="padding-left: 0px; margin-bottom: -0px">
        <div
          v-for="group in manhourStepGroups"
          :key="group[0].key"
          style="display: flex; gap: 12px"
        >
          <el-form-item :label="group[0].label" style="flex: 1">
            <el-input-number
              v-model="group[0].manhour"
              :min="0"
              :step="1"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <el-form-item v-if="group[1]" :label="group[1].label" style="flex: 1">
            <el-input-number
              v-model="group[1].manhour"
              :min="0"
              :step="1"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <div v-else style="flex: 1"></div>
          <el-form-item v-if="group[2]" :label="group[2].label" style="flex: 1">
            <el-input-number
              v-model="group[2].manhour"
              :min="0"
              :step="1"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <div v-else style="flex: 1"></div>
        </div>
      </el-form>

      <template #footer>
        <el-button @click="handleCloseManhourDialog">取消</el-button>
        <el-button type="primary" @click="handleConfirmManhourDialog">保存工时</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "ProduceBomManhour",
  inheritAttrs: false,
});

import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage } from "element-plus";
import {
  QuestionFilled,
  Expand,
  Fold,
  Collection,
  Refresh,
  Search,
} from "@element-plus/icons-vue";
import ProduceBomRouteAPI, {
  ProduceBomRoutePageQuery,
  ProduceBomRouteTable,
  ProduceBomRouteForm,
} from "@/api/module_produce/bomroute";
import DataBomAPI, { DataBomTable } from "@/api/module_data/bom";
import { DataProjectTable } from "@/api/module_data/project";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import ProduceCraftRouteAPI from "@/api/module_produce/craftroute";
import ProduceBomManhourAPI from "@/api/module_produce/bommanhour";
import { convertToTree } from "@/views/module_data/utils";

const visible = ref(true);
const tableRef = ref();
const queryFormRef = ref();
const dataFormRef = ref();
const total = ref(0);
const selectIds = ref<number[]>([]);
const selectionRows = ref<any[]>([]);
const loading = ref(false);

const manhourDialogVisible = ref(false);
const manhourLoading = ref(false);
const manhourBom = ref<any | null>(null);
const manhourSteps = ref<
  { key: string; label: string; craft_id: number; manhour: number | null }[]
>([]);

const manhourStepGroups = computed(() => {
  const groups: [
    { key: string; label: string; craft_id: number; manhour: number | null },
    { key: string; label: string; craft_id: number; manhour: number | null } | null,
    { key: string; label: string; craft_id: number; manhour: number | null } | null,
  ][] = [];
  for (let i = 0; i < manhourSteps.value.length; i += 3) {
    groups.push([
      manhourSteps.value[i],
      manhourSteps.value[i + 1] ?? null,
      manhourSteps.value[i + 2] ?? null,
    ]);
  }
  return groups;
});

// 分页表单
const pageTableData = ref<DataBomTable[]>([]);

// 工艺路线下拉选项
const craftRouteOptions = ref<any[]>([]);

// 项目选择相关
const projectDrawerVisible = ref(false);

// 表格列配置
const tableColumns = ref([
  { prop: "selection", label: "选择框", show: true },
  { prop: "code", label: "代号", show: true },
  { prop: "spec", label: "名称", show: true },
  { prop: "craft_route", label: "工艺路线", show: true },
  { prop: "count", label: "数量", show: true },
  { prop: "material", label: "材质", show: true },
  { prop: "unit_mass", label: "单重", show: true },
  { prop: "total_mass", label: "总重", show: true },
  { prop: "remark", label: "备注", show: true },
  { prop: "manhour", label: "工时", show: true },
  { prop: "operation", label: "操作", show: true },
]);

// 详情表单
const detailFormData = ref<ProduceBomRouteTable>({});

// 分页查询参数
type QueryFormData = ProduceBomRoutePageQuery & {
  parent_code?: string;
  code?: string;
  spec?: string;
};
const queryFormData = reactive<QueryFormData>({
  page_no: 1,
  page_size: 10,
  code: undefined,
  spec: undefined,
});

// 编辑表单
const formData = reactive<ProduceBomRouteForm>({
  bom_id: undefined,
  route: undefined,
});

// 弹窗状态
const dialogVisible = reactive({
  title: "",
  visible: false,
  type: "create" as "create" | "update" | "detail",
});

// 表单验证规则
const rules = reactive({
  bom_id: [{ required: false, message: "请输入BOMID", trigger: "blur" }],
  route: [{ required: false, message: "请输入工艺路线", trigger: "blur" }],
});

// 加载表格数据
// 全量缓存
const allBoms = ref<DataBomTable[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);
const routeCraftIdsCache = new Map<number, number[]>();

function getRouteName(routeCode: any) {
  const matched = (craftRouteOptions.value || []).find((opt: any) => opt.route_code === routeCode);
  return matched?.route_name;
}

function syncCraftRouteToTree(nodes: any[]) {
  if (!nodes) return;
  nodes.forEach((node: any) => {
    const routeRecord = allBomRoutes.value.find((r: any) => r.bom_id === node.id);
    if (routeRecord) {
      node.route_code = routeRecord.route;
      node.route_name = getRouteName(routeRecord.route);
      node.craft_route = routeRecord.route;
    } else {
      node.route_code = undefined;
      node.route_name = undefined;
    }
    if (node.children && node.children.length > 0) {
      syncCraftRouteToTree(node.children);
    }
  });
}

async function ensureAllBomRoutesLoaded() {
  if (allBomRoutes.value.length > 0) return;
  const routeRes = await ProduceBomRouteAPI.getAllProduceBomRoute();
  allBomRoutes.value = routeRes.data.data || [];
}

async function ensureRouteCraftIdsLoaded(routeCodes: number[]) {
  const unique = Array.from(new Set(routeCodes.filter((r) => Number.isFinite(r) && r > 0)));
  const missing = unique.filter((r) => !routeCraftIdsCache.has(r));
  if (missing.length === 0) return;

  const results = await Promise.all(
    missing.map(async (routeCode) => {
      try {
        const res = await ProduceCraftRouteAPI.detailProduceCraftRoute(routeCode);
        const items = res.data?.data?.items || [];
        const craftIds = items
          .map((i: any) => Number(i?.craft_id))
          .filter((id: number) => Number.isFinite(id) && id > 0);
        return { routeCode, craftIds };
      } catch {
        return { routeCode, craftIds: [] as number[] };
      }
    })
  );

  results.forEach(({ routeCode, craftIds }) => {
    routeCraftIdsCache.set(routeCode, craftIds);
  });
}

function collectSubtreeByRootCode(list: any[], rootCode: string) {
  const childrenByParentCode: Record<string, any[]> = {};
  list.forEach((item: any) => {
    const key = item.parent_code || "";
    if (!childrenByParentCode[key]) childrenByParentCode[key] = [];
    childrenByParentCode[key].push(item);
  });

  const results: any[] = [];
  const visited = new Set<any>();
  const roots = list.filter((item: any) => item.code === rootCode);
  const queue: any[] = [...roots];

  while (queue.length > 0) {
    const node = queue.shift();
    const visitKey = node?.id ?? `${node?.code}|${node?.parent_code}|${node?.borrow ?? ""}`;
    if (visited.has(visitKey)) continue;
    visited.add(visitKey);
    results.push(node);
    const children = childrenByParentCode[node.code] || [];
    children.forEach((child: any) => queue.push(child));
  }
  return results;
}

async function loadingData() {
  if (!selectedRootBomCode.value && !queryFormData.parent_code) {
    pageTableData.value = [];
    total.value = 0;
    return;
  }

  ElMessage.info("正在更新数据... ...请稍后");
  loading.value = true;
  try {
    await Promise.all([ensureAllBomsLoaded(), ensureAllBomRoutesLoaded()]);

    allBoms.value.forEach((bom: any) => {
      const routeRecord = allBomRoutes.value.find((r: any) => r.bom_id === bom.id);
      if (routeRecord) {
        bom.route_code = routeRecord.route;
        bom.route_name = getRouteName(routeRecord.route);
        bom.craft_route = routeRecord.route;
      } else {
        bom.route_code = undefined;
        bom.route_name = undefined;
      }
    });

    let displayNodes = [];
    if (selectedRootBomCode.value) {
      displayNodes = collectSubtreeByRootCode(allBoms.value as any[], selectedRootBomCode.value);
    } else {
      displayNodes = allBoms.value;
    }

    // 前端过滤
    if (queryFormData.code) {
      const codeLower = queryFormData.code.toLowerCase();
      displayNodes = displayNodes.filter((node: any) =>
        node.code?.toLowerCase().includes(codeLower)
      );
    }
    if (queryFormData.spec) {
      const specLower = queryFormData.spec.toLowerCase();
      displayNodes = displayNodes.filter((node: any) =>
        node.spec?.toLowerCase().includes(specLower)
      );
    }

    const bomIds = Array.from(
      new Set(
        displayNodes.map((b: any) => Number(b?.id)).filter((id: number) => Number.isFinite(id) && id > 0)
      )
    );
    await ensureRouteCraftIdsLoaded(
      displayNodes
        .map((b: any) => Number(b?.route_code))
        .filter((v: number) => Number.isFinite(v) && v > 0)
    );
    if (bomIds.length > 0) {
      const manhourRes = await ProduceBomManhourAPI.summaryBatchProduceBomManhour({
        bom_ids: bomIds,
        recursive: false,
      });
      const manhourMap = manhourRes.data?.data || {};
      displayNodes.forEach((bom: any) => {
        bom.manhour = manhourMap[String(bom.id)] || [];
      });
    }

    const { tree } = convertToTree(
      displayNodes,
      selectedRootBomCode.value ? undefined : queryFormData.parent_code,
      selectedRootBomCode.value
    );
    syncCraftRouteToTree(tree);
    pageTableData.value = tree;
    total.value = tree.length;
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

async function ensureAllBomsLoaded() {
  if (allBoms.value.length > 0) return;
  const res = await DataBomAPI.listDataBomNoProcure();
  allBoms.value = res.data.data || [];
}

// 查询（重置页码后获取数据）
async function handleQuery() {
  queryFormData.page_no = 1;
  loadingData();
}

// 重置查询
async function handleResetQuery() {
  queryFormData.parent_code = undefined;
  queryFormData.code = undefined;
  queryFormData.spec = undefined;
  selectedRootBomCode.value = undefined;
  allBoms.value = [];
  handleQuery();
}

// 展开/收起所有行
function toggleAllExpansion(expanded: boolean) {
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

// 打开项目选择抽屉
async function handleOpenProjectDrawer() {
  projectDrawerVisible.value = true;
}

// 选择项目
function handleSelectProject(project: DataProjectTable) {
  selectedRootBomCode.value = undefined;
  queryFormData.parent_code = project.code;
  projectDrawerVisible.value = false;
  allBoms.value = [];
  handleQuery();
}

// 定义初始表单数据常量
const initialFormData: ProduceBomRouteForm = {
  bom_id: undefined,
  route: undefined,
};

// 重置表单
async function resetForm() {
  if (dataFormRef.value) {
    dataFormRef.value.resetFields();
    dataFormRef.value.clearValidate();
  }
  // 完全重置 formData 为初始状态
  Object.assign(formData, initialFormData);
}

// 加载工艺路线下拉选项
async function loadCraftRouteOptions() {
  try {
    const response = await ProduceCraftRouteAPI.getAllProduceCraftRoute();
    craftRouteOptions.value = response.data.data || [];
  } catch (error: any) {
    console.error(error);
  }
}

function updateTreeManhourById(nodes: any[], bomId: number, manhour: any[]): boolean {
  for (const node of nodes || []) {
    if (node.id === bomId) {
      node.manhour = manhour;
      return true;
    }
    if (node.children && node.children.length > 0) {
      const updated = updateTreeManhourById(node.children, bomId, manhour);
      if (updated) return true;
    }
  }
  return false;
}

// 行复选框选中项变化
async function handleSelectionChange(selection: any) {
  selectIds.value = selection.map((item: any) => item.id);
  selectionRows.value = selection;
}

// 关闭弹窗
async function handleCloseDialog() {
  dialogVisible.visible = false;
  resetForm();
}

// 打开弹窗
async function handleOpenDialog(type: "create" | "update" | "detail", id?: number) {
  dialogVisible.type = type;
  if (id) {
    const response = await ProduceBomRouteAPI.detailProduceBomRoute(id);
    if (type === "detail") {
      dialogVisible.title = "详情";
      Object.assign(detailFormData.value, response.data.data);
    } else if (type === "update") {
      dialogVisible.title = "修改";
      Object.assign(formData, response.data.data);
    }
  } else {
    dialogVisible.title = "新增";
    formData.bom_id = undefined;
    formData.route = undefined;
  }
  dialogVisible.visible = true;
}

// 提交表单（防抖）
async function handleSubmit() {
  // 表单校验
  dataFormRef.value.validate(async (valid: any) => {
    if (valid) {
      loading.value = true;
      const submitData = { ...formData };
      try {
        if (dialogVisible.type === "create") {
          await ProduceBomRouteAPI.createProduceBomRoute(submitData);
          ElMessage.success("新增成功");
        } else if (dialogVisible.type === "update") {
          await ProduceBomRouteAPI.updateProduceBomRoute(submitData.id as number, submitData);
          ElMessage.success("修改成功");
        }
        handleCloseDialog();
        loadingData();
      } catch (error: any) {
        console.error(error);
      } finally {
        loading.value = false;
      }
    }
  });
}

function isManhourComplete(row: any) {
  const routeCode = Number(row.route_code);
  if (!routeCode) return false;
  const craftIds = routeCraftIdsCache.get(routeCode) || [];
  if (craftIds.length === 0) return false;
  const recorded = (row.manhour || []).map((m: any) => m.craft_id);
  return craftIds.every((id) => recorded.includes(id));
}

async function handleOpenManhourDialog(row: any) {
  manhourBom.value = row;
  manhourLoading.value = true;
  manhourDialogVisible.value = true;

  try {
    const routeCode = Number(row.route_code);
    if (!routeCode) {
      manhourSteps.value = [];
      return;
    }
    const routeRes = await ProduceCraftRouteAPI.detailProduceCraftRoute(routeCode);
    const steps = routeRes.data?.data?.items || [];
    const manhourRes = await ProduceBomManhourAPI.getAllProduceBomManhour({
      bom_id: String(row.id),
    });
    const records = manhourRes.data?.data || [];

    manhourSteps.value = steps.map((s: any) => {
      const match = records.find((r: any) => Number(r.craft_id) === Number(s.craft_id));
      return {
        key: `${s.craft_id}`,
        label: s.craft_name,
        craft_id: Number(s.craft_id),
        manhour: match ? Number(match.manhour) : null,
      };
    });
  } catch (err) {
    console.error(err);
  } finally {
    manhourLoading.value = false;
  }
}

function handleCloseManhourDialog() {
  manhourDialogVisible.value = false;
  manhourBom.value = null;
  manhourSteps.value = [];
}

async function handleConfirmManhourDialog() {
  if (!manhourBom.value) return;
  try {
    const items = manhourSteps.value
      .filter((s) => s.manhour !== null)
      .map((s) => ({
        bom_id: Number(manhourBom.value.id),
        craft_id: s.craft_id,
        manhour: Number(s.manhour),
      }));

    await ProduceBomManhourAPI.upsertBatchProduceBomManhour({ items });
    ElMessage.success("保存成功");

    const summaryRes = await ProduceBomManhourAPI.summaryBatchProduceBomManhour({
      bom_ids: [manhourBom.value.id],
      recursive: false,
    });
    const manhourList = summaryRes.data?.data?.[String(manhourBom.value.id)] || [];
    updateTreeManhourById(pageTableData.value, manhourBom.value.id, manhourList);

    handleCloseManhourDialog();
  } catch (err) {
    console.error(err);
  }
}

onMounted(async () => {
  await loadCraftRouteOptions();
  pageTableData.value = [];
});
</script>

<style lang="scss" scoped></style>
