<!-- BOM路线关联 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <div class="flex-x-between">
          <div class="flex-x-start">
            <el-button type="info" plain :icon="Expand" @click="toggleAllExpansion(true)">
              展开
            </el-button>
            <el-button type="info" plain :icon="Fold" @click="toggleAllExpansion(false)">
              收起
            </el-button>
          </div>
          <div class="flex-x-end">
            <el-button type="primary" :icon="Collection" @click="handleOpenProjectDrawer">
              项目
            </el-button>
          </div>
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
          <template #default="{ row }">
            <el-tooltip placement="top" effect="dark">
              <template #content>
                <div>{{ row.route_name || getRouteName(row.route_code) || '暂无路线名称' }}</div>
              </template>
              <span style="font-size: 14px; cursor: pointer">
                {{ row.route_code }}
              </span>
            </el-tooltip>
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
                    {{ item.craft_name }}：{{ item.id }}：{{ item.manhour }}
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
    <ProjectSelectDrawer 
      v-model="projectDrawerVisible" 
      :show-bom-table="true"
      :show-order-column="false"
      @select="handleSelectProject" 
    />

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
  Expand,
  Fold,
  Collection,
} from "@element-plus/icons-vue";
import ProduceBomRouteAPI from "@/api/module_produce/bomroute";
import DataBomAPI, { DataBomTable } from "@/api/module_data/bom";
import { DataProjectTable } from "@/api/module_data/project";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import ProduceCraftRouteAPI from "@/api/module_produce/craftroute";
import ProduceBomManhourAPI from "@/api/module_produce/bommanhour";
import { convertToTree } from "@/views/module_data/utils";

const tableRef = ref();
const total = ref(0);
const selectIds = ref<number[]>([]);
const selectionRows = ref<any[]>([]);
const loading = ref(false);

const manhourDialogVisible = ref(false);
const manhourLoading = ref(false);
const manhourBom = ref<any | null>(null);
const manhourSteps = ref<
  { id?: number; key: string; label: string; craft_id: number; manhour: number | null }[]
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

// 查询参数
const queryFormData = reactive({
  parent_code: undefined as string | undefined,
});

// 加载表格数据
// 全量缓存
const allBoms = ref<DataBomTable[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);
const routeCraftItemsCache = new Map<number, any[]>();

function getRouteName(routeCode: any) {
  const matched = (craftRouteOptions.value || []).find((opt: any) => opt.route_code === routeCode);
  return matched?.route_name;
}

function syncCraftRouteToFullList() {
  if (!allBoms.value || allBoms.value.length === 0) return;
  
  // 建立 route 映射 Map，用于快速查找
  const routeMap = new Map(allBomRoutes.value.map(r => [r.bom_id, r.route]));

  // 直接在扁平列表上同步数据，这样后续生成的树也会带上这些值
  allBoms.value.forEach((node: any) => {
    const route = routeMap.get(node.id);
    if (route !== undefined) {
      node.route_code = route;
      node.route_name = getRouteName(route);
      node.craft_route = route;
    } else {
      node.route_code = undefined;
      node.route_name = undefined;
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
  const missing = unique.filter((r) => !routeCraftItemsCache.has(r));
  if (missing.length === 0) return;

  const results = await Promise.all(
    missing.map(async (routeCode) => {
      try {
        const res = await ProduceCraftRouteAPI.detailProduceCraftRoute(routeCode);
        const items = res.data?.data?.items || [];
        return { routeCode, items };
      } catch {
        return { routeCode, items: [] as any[] };
      }
    })
  );

  results.forEach(({ routeCode, items }) => {
    routeCraftItemsCache.set(routeCode, items);
  });
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
    await ensureAllBomRoutesLoaded();
    
    // 1. 同步工艺路线到扁平列表 (源数据同步)
    syncCraftRouteToFullList();

    let displayNodes = [...allBoms.value];

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

    // 2. 直接转换为树形结构
    const { tree } = convertToTree(
      displayNodes,
      selectedRootBomCode.value ? undefined : queryFormData.parent_code,
      selectedRootBomCode.value
    );

    // 3. 渲染页面
    pageTableData.value = tree;
    total.value = tree.length;
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

// 查询（获取数据）
async function handleQuery() {
  await loadingData();
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
function handleSelectProject(project: any) {
  // 仅处理从预览面板选中的逻辑（带有递归数据）
  if (project.recursive_data && project.root_bom_code) {
    queryFormData.parent_code = project.code;
    projectDrawerVisible.value = false;
    selectedRootBomCode.value = project.root_bom_code;
    // 直接注入数据，不再有全量拉取逻辑
    allBoms.value = project.recursive_data;
    handleQuery();
  }
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

// 检查工时是否完整
function isManhourComplete(row: any) {
  const routeCode = Number(row.route_code);
  if (!routeCode) return false;
  const craftItems = routeCraftItemsCache.get(routeCode) || [];
  if (craftItems.length === 0) return false;

  const recorded = row.manhour || [];
  const recordedCount = recorded.length;

  // 计算最小值
  let min = 0;
  const parentGroups = new Set<number>();
  craftItems.forEach((item: any) => {
    if (item.parent_id === null || item.parent_id === undefined || item.parent_id === 0) {
      // 没有父工艺的元素，最小值+1
      min += 1;
    } else {
      // 有父工艺的元素，按父工艺ID去重，每组计为一次 min+1
      parentGroups.add(Number(item.parent_id));
    }
  });
  min += parentGroups.size;

  // 计算最大值
  const max = craftItems.length;
  return recordedCount >= min && recordedCount <= max;
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
        id: match ? match.id : undefined
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
