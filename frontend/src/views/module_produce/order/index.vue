<template>
  <div class="app-container">
    <el-card class="data-table">
      <template #header>
        <div class="flex-x-between">
          <div class="flex-x-start">
            <!-- <el-button type="info" plain :icon="Expand" @click="toggleAllExpansion(true)">
              展开
            </el-button>
            <el-button type="info" plain :icon="Fold" @click="toggleAllExpansion(false)">
              收起
            </el-button> -->
          </div>
          <div class="flex-x-end">
            <el-button type="primary" :icon="Collection" @click="handleOpenProjectDrawer">
              项目
            </el-button>
          </div>
        </div>
      </template>

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
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column type="selection" min-width="40" align="center" />
        <el-table-column
          label="代号"
          prop="code"
          min-width="160"
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
          label="单号"
          prop="no"
          min-width="70"
          align="center"
          header-align="center"
          fixed="right"
          show-overflow-tooltip
        />
        <el-table-column
          label="工艺路线"
          min-width="330"
          header-align="center"
          fixed="right"
        >
          <template #default="{ row }">
            <span v-if="row.route_code">{{ row.route_code }} {{ row.route_name }}</span>
          </template>
        </el-table-column>
        <el-table-column
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
        
        <el-table-column fixed="right" label="操作" align="center" min-width="60">
          <template #default="{ row }">
            <el-button
              v-hasPerm="['module_produce:bommanhour:update']"
              type="primary"
              link
              @click="handleOpenManhourDialog(row)"
            >
              排产
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 项目选择抽屉 -->
    <ProjectSelectDrawer 
      v-model="projectDrawerVisible" 
      :show-bom-table="false"
      @select="handleSelectProject" 
    />

    <!-- 排产弹窗 -->
    <el-dialog
      v-model="manhourDialogVisible"
      title="创建工单"
      width="1100px"
      top="5vh"
      destroy-on-close
    >
      <el-table v-if="manhourBom" :data="[manhourBom]" border>
        <el-table-column prop="code" label="代号" align="center" width="190" />
        <el-table-column
          prop="spec"
          label="名称"
          align="center"
          width="170"
          show-overflow-tooltip
        />
        <el-table-column
          prop="material"
          label="材质"
          align="center"
          width="155"
          show-overflow-tooltip
        />
        <el-table-column prop="count" label="数量" align="center" width="80" />
        <el-table-column prop="unit_mass" label="单重" align="center" width="110" />
        <el-table-column prop="total_mass" label="总重" align="center" width="110" />
        <el-table-column prop="remark" label="备注" align="center" show-overflow-tooltip />
      </el-table>

      <el-divider />
      <el-skeleton v-if="manhourLoading" :rows="6" animated />
      <el-empty v-else-if="manhourSteps.length === 0" description="该路线未配置工艺" />

      <!-- 外层左右分栏容器 -->
      <div style="display: flex; gap: 0px">
        <!-- 左侧表格：显示前一半数据 -->
        <el-table :data="manhourStepsLeft" border stripe header-align="center" style="flex: 1">
          <el-table-column label="工艺" width="80" align="center">
            <template #default="{ row }">
              <el-tag
                style="font-size: 14px; background: #e8f3ff; color: #1989fa; border-color: #dcdfe6"
              >
                {{ row.label }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="工时" width="110" align="center">
            <template #default="{ row }"><el-input v-model="row.manhour" disabled /></template>
          </el-table-column>
          <el-table-column label="计划日期" width="170" align="center">
            <template #default="{ row }">
              <el-date-picker v-model="row.date" type="date" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="计划用户" min-width="140" align="center">
            <template #default="{ row }">
              <el-select v-model="row.tag" filterable clearable style="width: 100%">
                <el-option
                  v-for="name in row.staffOptions || []"
                  :key="name"
                  :label="name"
                  :value="name"
                />
              </el-select>
            </template>
          </el-table-column>
        </el-table>

        <!-- 右侧表格：显示后一半数据 -->
        <el-table :data="manhourStepsRight" border stripe header-align="center" style="flex: 1">
          <el-table-column label="工艺" width="80" align="center">
            <template #default="{ row }">
              <el-tag
                style="font-size: 14px; background: #e8f3ff; color: #1989fa; border-color: #dcdfe6"
              >
                {{ row.label }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="工时" width="110" align="center">
            <template #default="{ row }"><el-input v-model="row.manhour" disabled /></template>
          </el-table-column>
          <el-table-column label="计划日期" width="170" align="center">
            <template #default="{ row }">
              <el-date-picker v-model="row.date" type="date" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="计划用户" min-width="140" align="center">
            <template #default="{ row }">
              <el-select v-model="row.tag" filterable clearable style="width: 100%">
                <el-option
                  v-for="name in row.staffOptions || []"
                  :key="name"
                  :label="name"
                  :value="name"
                />
              </el-select>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <template #footer>
        <el-button @click="manhourDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="manhourLoading" @click="handleConfirmManhourDialog">
          保存工单
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "ProduceOrder",
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
import DataProjectAPI, { DataProjectTable } from "@/api/module_data/project";
import ProduceCraftRouteAPI from "@/api/module_produce/craftroute";
import ProduceBomManhourAPI from "@/api/module_produce/bommanhour";
import ProduceOrderAPI from "@/api/module_produce/order";
import ProduceCraftAPI from "@/api/module_produce/craft";
import PositionAPI from "@/api/module_system/position";
import UserAPI, { UserInfo } from "@/api/module_system/user";
import { convertToTree } from "@/views/module_data/utils";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";

/**
 * 接口与类型定义
 */
interface ManhourStep {
  key: string;
  label: string;
  craft_id: number;
  manhour: number | null;
  date: string | null;
  tag: string | null;
  staffOptions: string[];
}

interface CraftCacheItem {
  id: number;
  name: string;
  parent_id?: number;
}

/**
 * 状态声明
 */
const tableRef = ref();
const total = ref(0);
const loading = ref(false);
const pageTableData = ref<DataBomTable[]>([]);

// 排产弹窗相关
const manhourDialogVisible = ref(false);
const manhourLoading = ref(false);
const manhourBom = ref<DataBomTable | null>(null);
const manhourSteps = ref<ManhourStep[]>([]);

const manhourStepsLeft = computed(() => manhourSteps.value.filter((_, idx) => idx % 2 === 0));
const manhourStepsRight = computed(() => manhourSteps.value.filter((_, idx) => idx % 2 === 1));

// 缓存数据
const craftByIdCache = new Map<number, CraftCacheItem>();
const positionNameToIdCache = new Map<string, number>();
const usersCache = ref<UserInfo[]>([]);
const routeCraftIdsCache = new Map<number, number[]>();
const craftRouteOptions = ref<any[]>([]);

// 全量 BOM 数据
const allBoms = ref<DataBomTable[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);
const selectedProjectCode = ref<string | undefined>(undefined);

const queryFormData = reactive({
  page_no: 1,
  page_size: 20,
  parent_code: undefined as string | undefined,
});

const projectDrawerVisible = ref(false);
const projectLoading = ref(false);
const projectList = ref<DataProjectTable[]>([]);
const projectTotal = ref(0);
const projectSearch = ref("");
const projectQuery = reactive({
  page_no: 1,
  page_size: 20,
});
const routeCraftItemsCache = new Map<number, any[]>();


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

// 选择项目
function handleSelectProject(project: any) {
  if (!project) return;
  
  // 1. 如果是从预览面板选中的逻辑（带有递归数据）
  if (project.recursive_data && project.root_bom_code) {
    queryFormData.parent_code = project.code;
    selectedProjectCode.value = project.code;
    projectDrawerVisible.value = false;
    selectedRootBomCode.value = project.root_bom_code;
    // 直接注入数据，不再有全量拉取逻辑
    allBoms.value = project.recursive_data;
    handleQuery();
  } else {
    // 2. 如果是直接点击项目选中的逻辑
    queryFormData.parent_code = project.code;
    selectedProjectCode.value = project.code;
    selectedRootBomCode.value = undefined;
    projectDrawerVisible.value = false;
    // 清空数据，触发后续 fetch
    allBoms.value = [];
    handleQuery();
  }
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

/**
 * 辅助工具函数
 */
function normalizeText(v: string) {
  return String(v ?? "")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "");
}

function getUserIdByName(name: string): number | undefined {
  const n = normalizeText(name);
  if (!n) return undefined;
  const u = usersCache.value.find((x) => normalizeText(x?.name || x?.username || "") === n);
  return u?.id ? Number(u.id) : undefined;
}

function getUserNameById(id: number | string): string | undefined {
  const uid = Number(id);
  if (!Number.isFinite(uid) || uid <= 0) return undefined;
  const u = usersCache.value.find((x) => Number(x?.id) === uid);
  return u?.name || u?.username || undefined;
}

function getCraftMatchName(craftId: number): string {
  const craft = craftByIdCache.get(craftId);
  if (!craft) return "";
  const parentId = Number(craft.parent_id);
  if (parentId > 0) {
    const parent = craftByIdCache.get(parentId);
    return parent?.name ?? "";
  }
  return craft.name ?? "";
}

function findPositionIdByCraftName(craftName: string): number | undefined {
  const target = normalizeText(craftName);
  if (!target) return undefined;
  for (const [name, id] of positionNameToIdCache.entries()) {
    if (normalizeText(name).includes(target)) return id;
  }
  return undefined;
}

function getStaffNamesByCraftName(craftName: string): string[] {
  const positionId = findPositionIdByCraftName(craftName);
  if (!positionId) return [];
  const names = usersCache.value
    .filter((u) => {
      const ids = (u?.position_ids || []) as any[];
      if (ids.map(Number).includes(positionId)) return true;
      const positions = (u?.positions || []) as any[];
      return positions.some((p: any) => Number(p?.id) === positionId);
    })
    .map((u) => u?.name || u?.username || "")
    .filter(Boolean);
  return Array.from(new Set(names));
}

function getRouteName(routeCode: any) {
  const matched = craftRouteOptions.value.find((opt: any) => opt.route_code === routeCode);
  return matched?.route_name;
}

/**
 * 数据预加载
 */
async function ensureCraftsLoaded() {
  if (craftByIdCache.size > 0) return;
  const res = await ProduceCraftAPI.getAllProduceCraft();
  (res.data?.data || []).forEach((c: any) => {
    const id = Number(c?.id);
    if (id > 0) craftByIdCache.set(id, { id, name: c?.name, parent_id: c?.parent_id });
  });
}

async function ensurePositionsLoaded() {
  if (positionNameToIdCache.size > 0) return;
  const res = await PositionAPI.listPosition({ page_no: 1, page_size: 100 } as any);
  (res.data?.data?.items || []).forEach((p: any) => {
    const id = Number(p?.id);
    const name = String(p?.name ?? "");
    if (id > 0 && name) positionNameToIdCache.set(name, id);
  });
}

async function ensureUsersLoaded() {
  if (usersCache.value.length > 0) return;
  const res = await UserAPI.listUser({ page_no: 1, page_size: 100 } as any);
  usersCache.value = (res.data?.data?.items || []) as UserInfo[];
}

async function ensureAllBomRoutesLoaded() {
  if (allBomRoutes.value.length > 0) return;
  const routeRes = await ProduceBomRouteAPI.getAllProduceBomRoute();
  allBomRoutes.value = routeRes.data.data || [];
}

async function ensureAllBomsLoaded() {
  // 如果已经有数据了，说明可能是从预览面板选中的（带有递归数据），不再重复拉取
  if (allBoms.value.length > 0) return;

  const projectCode = selectedProjectCode.value || queryFormData.parent_code;
  if (!projectCode) {
    allBoms.value = [];
    return;
  }

  try {
    const res = await DataBomAPI.listProjectBoms(projectCode);
    allBoms.value = res.data.data || [];
  } catch (error) {
    console.error("Fetch all boms error:", error);
    allBoms.value = [];
  }
}

async function ensureRouteCraftIdsLoaded(routeCodes: number[]) {
  const unique = Array.from(new Set(routeCodes.filter((r) => r > 0)));
  const missing = unique.filter((r) => !routeCraftIdsCache.has(r));
  if (missing.length === 0) return;

  await Promise.all(
    missing.map(async (routeCode) => {
      try {
        const res = await ProduceCraftRouteAPI.detailProduceCraftRoute(routeCode);
        const items = res.data?.data?.items || [];
        const craftIds = items.map((i: any) => Number(i?.craft_id)).filter((id: number) => id > 0);
        routeCraftIdsCache.set(routeCode, craftIds);
      } catch {
        routeCraftIdsCache.set(routeCode, []);
      }
    })
  );
}

/**
 * 列表加载逻辑
 */
function collectSubtree(list: DataBomTable[], key: string, isParentCode = false) {
  const childrenMap: Record<string, DataBomTable[]> = {};
  list.forEach((item) => {
    const p = item.parent_code || "";
    if (!childrenMap[p]) childrenMap[p] = [];
    childrenMap[p].push(item);
  });

  const results: DataBomTable[] = [];
  const visited = new Set<string>();
  const roots = isParentCode ? childrenMap[key] || [] : list.filter((i) => i.code === key);
  const queue: DataBomTable[] = [...roots];

  while (queue.length > 0) {
    const node = queue.shift();
    if (!node) continue;
    const vKey = String(node.id || `${node.code}|${node.parent_code}`);
    if (visited.has(vKey)) continue;
    visited.add(vKey);
    results.push(node);
    (childrenMap[node.code || ""] || []).forEach((c) => queue.push(c));
  }
  return results;
}

async function loadingData() {
  if (!selectedRootBomCode.value && !selectedProjectCode.value) {
    pageTableData.value = [];
    total.value = 0;
    return;
  }

  ElMessage.info("正在更新列表数据...");
  loading.value = true;
  try {
    await Promise.all([ensureAllBomsLoaded(), ensureAllBomRoutesLoaded()]);

    allBoms.value.forEach((bom: any) => {
      const route = allBomRoutes.value.find((r) => r.bom_id === bom.id);
      if (route) {
        bom.route_code = route.route;
        bom.route_name = getRouteName(route.route);
        bom.craft_route = route.route;
      }
    });

    let displayList: any[] = [];
    let manhourScope: any[] = [];
    if (selectedRootBomCode.value) {
      displayList = collectSubtree(allBoms.value, selectedRootBomCode.value);
      manhourScope = displayList;
    } else if (selectedProjectCode.value) {
      displayList = allBoms.value.filter((b) => b.parent_code === selectedProjectCode.value);
      manhourScope = collectSubtree(allBoms.value, selectedProjectCode.value, true);
    }

    await ensureRouteCraftIdsLoaded(
      displayList.map((b) => Number(b.route_code)).filter((v) => v > 0)
    );

    const bomIds = displayList.map((b) => Number(b.id)).filter((id) => id > 0);

    if (bomIds.length > 0) {
      const [manhourRes, orderRes] = await Promise.all([
        ProduceBomManhourAPI.summaryBatchProduceBomManhour({ bom_ids: bomIds }),
        ProduceOrderAPI.summaryBatchProduceOrder({ bom_ids: bomIds }),
      ]);
      const manhourMap = manhourRes.data?.data || {};
      const orderMap = orderRes.data?.data || {};

      const childrenMap: Record<string, DataBomTable[]> = {};
      allBoms.value.forEach((b) => {
        const p = b.parent_code || "";
        if (!childrenMap[p]) childrenMap[p] = [];
        childrenMap[p].push(b);
      });

      await ensureCraftsLoaded();

      displayList.forEach((bom) => {
        const craftRecords = manhourMap[String(bom.id)] || [];
        bom.manhour = craftRecords; // 存储原始工时列表
        bom.no = orderMap[String(bom.id)] || "";
      });
    }

    if (selectedRootBomCode.value) {
      const { tree } = convertToTree(displayList, undefined, selectedRootBomCode.value);
      pageTableData.value = tree;
    } else {
      pageTableData.value = displayList.map((b) => ({ ...b, _tree_id: b.id || b.code }));
    }
    total.value = pageTableData.value.length;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

async function handleQuery() {
  await loadingData();
}

/**
 * 项目选择业务
 */
async function fetchProjects() {
  projectLoading.value = true;
  try {
    const res = await DataProjectAPI.listDataProject({
      page_no: projectQuery.page_no,
      page_size: projectQuery.page_size,
      keyword: projectSearch.value || undefined,
    } as any);
    projectList.value = (res.data.data.items as DataProjectTable[]) || [];
    projectTotal.value = res.data.data.total || 0;
  } finally {
    projectLoading.value = false;
  }
}

async function handleOpenProjectDrawer() {
  projectDrawerVisible.value = true;
  await fetchProjects();
}

/**
 * 排产弹窗业务
 */
async function handleOpenManhourDialog(row: any) {
  manhourBom.value = row;
  manhourDialogVisible.value = true;
  manhourSteps.value = [];
  const routeCode = row?.route_code ?? row?.craft_route;
  if (!routeCode) return;

  manhourLoading.value = true;
  try {
    const subtree = collectSubtree(allBoms.value, row.code);
    const bomIds = subtree.map((b) => Number(b.id)).filter((id) => id > 0);

    const [routeRes, manhourRes, orderRes] = await Promise.all([
      ProduceCraftRouteAPI.detailProduceCraftRoute(Number(routeCode)),
      ProduceBomManhourAPI.summaryCraftBatchProduceBomManhour({ bom_ids: bomIds }),
      ProduceOrderAPI.listProduceOrder({
        bom_id: String(row.id),
        page_no: 1,
        page_size: 100,
      } as any),
    ]);

    const items = routeRes.data?.data?.items || [];
    const manhourData = manhourRes.data?.data || {};
    const orders = (orderRes.data?.data?.items || []) as any[];
    const orderMap = new Map(orders.map((o) => [Number(o.craft_id), o]));

    const craftTotals: Record<number, number> = {};
    Object.values(manhourData).forEach((map: any) => {
      Object.entries(map).forEach(([cid, v]) => {
        craftTotals[Number(cid)] = (craftTotals[Number(cid)] || 0) + Number(v);
      });
    });

    await Promise.all([ensureCraftsLoaded(), ensureUsersLoaded()]);
    manhourSteps.value = items
      .filter((i: any) => {
        const cid = Number(i.craft_id);
        const craft = craftByIdCache.get(cid);
        return Number(craft?.parent_id) === 0 || (craftTotals[cid] || 0) > 0;
      })
      .map((i: any) => {
        const cid = Number(i.craft_id);
        const order = orderMap.get(cid);
        return {
          key: `${i.route ?? routeCode}-${cid}`,
          label: (i.craft_name || i.craft_names || String(cid)).trim(),
          craft_id: cid,
          manhour: craftTotals[cid] || null,
          date: order?.plan_date ?? null,
          tag: order?.plan_user ? getUserNameById(order.plan_user) : null,
          staffOptions: [],
        } as ManhourStep;
      });

    await ensurePositionsLoaded();
    manhourSteps.value.forEach((s) => {
      const name = getCraftMatchName(s.craft_id);
      s.staffOptions = name ? getStaffNamesByCraftName(name) : [];
    });
  } finally {
    manhourLoading.value = false;
  }
}

async function handleConfirmManhourDialog() {
  const bomId = Number(manhourBom.value?.id);
  const existingNo = manhourBom.value?.no;
  if (!bomId) return;

  const toDateStr = (v: any) => {
    if (!v) return null;
    const d = new Date(v);
    return isNaN(d.getTime())
      ? null
      : `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  };

  const items = manhourSteps.value
    .map((s) => {
      const uid = s.tag ? getUserIdByName(s.tag) : undefined;
      return {
        no: existingNo,
        bom_id: bomId,
        craft_id: s.craft_id,
        man_hour: Number(s.manhour || 0),
        plan_date: toDateStr(s.date),
        plan_user: uid,
        plan_count: 1,
        status: "0",
        description: s.tag ? `计划用户:${s.tag}` : undefined,
      };
    })
    .filter((i) => i.man_hour > 0 && i.plan_date && i.plan_user);

  if (items.length === 0) {
    ElMessage.warning("请填写完整的计划日期与负责人");
    return;
  }

  try {
    manhourLoading.value = true;
    await ProduceOrderAPI.upsertBatchProduceOrder({ items: items as any });
    manhourDialogVisible.value = false;
    ElMessage.success("工单保存成功");
    await loadingData();
  } finally {
    manhourLoading.value = false;
  }
}

onMounted(async () => {
  const res = await ProduceCraftRouteAPI.getAllProduceCraftRoute();
  craftRouteOptions.value = res.data.data || [];
});
</script>

<!-- <style lang="scss" scoped>
.manhour-tables-container {
  display: flex;
  gap: 20px;
  margin-top: 10px;
}

.manhour-table-wrapper {
  flex: 1;
  min-width: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-container {
  margin-top: 15px;
}

.mb-4 {
  margin-bottom: 1rem;
}

.mt-4 {
  margin-top: 1rem;
}

.flex {
  display: flex;
}

.justify-end {
  justify-content: flex-end;
}
</style> -->
