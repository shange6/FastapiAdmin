<!-- BOM路线关联 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <!-- <div class="card-header">
          <span>
            BOM路线关联列表
            <el-tooltip content="BOM路线关联列表">
              <QuestionFilled class="w-4 h-4 mx-1" />
            </el-tooltip>
          </span>
        </div> -->

        <!-- 搜索区域 -->
        <div class="search-container">
          <el-form
            ref="queryFormRef"
            :model="queryFormData"
            label-suffix=":"
            :inline="true"
            @submit.prevent="handleQuery"
          >
            <!-- 查询、重置、展开/收起按钮 -->
            <el-form-item>
              <!-- <el-button
                v-hasPerm="['module_produce:bomroute:query']"
                type="primary"
                icon="search"
                @click="handleQuery"
              >
                查询
              </el-button>
              <el-button
                v-hasPerm="['module_produce:bomroute:query']"
                icon="refresh"
                @click="handleResetQuery"
              >
                重置
              </el-button> -->
              <el-button type="info" plain icon="Expand" @click="toggleAllExpansion(true)">
                展开
              </el-button>
              <el-button type="info" plain icon="Fold" @click="toggleAllExpansion(false)">
                收起
              </el-button>
              <el-button
                v-hasPerm="['module_produce:bomroute:create']"
                type="warning"
                icon="FolderChecked"
                @click="handleBatchSaveCraftRoute"
              >
                保存
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
          type="selection"
          min-width="40"
          align="center"
        />
        <el-table-column
          fixed="left"
          label="代号"
          prop="code"
          min-width="260"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          fixed="left"
          label="ID"
          prop="id"
          min-width="80"
          align="center"
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
          show-overflow-tooltip
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
          min-width="100"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          label="工艺路线"
          prop="craft_route"
          min-width="370"
          align="center"
          header-align="center"
          show-overflow-tooltip
          fixed="right"
        >
          <template #default="scope">
            <el-select
              v-model="scope.row.craft_route"
              placeholder="请选择工艺路线"
              clearable
              filterable
              default-first-option
              style="width: 100%"
              @change="handleCraftRouteChange(scope.row)"
            >
              <el-option
                v-for="item in craftRouteOptions"
                :key="item.route_code"
                :label="`${item.route_code} ${item.route_name}`"
                :value="item.route_code"
              />
            </el-select>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 项目选择抽屉 -->
    <ProjectSelectDrawer v-model="projectDrawerVisible" @select="handleSelectProject" />
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "ProduceBomRoute",
  inheritAttrs: false,
});

import { ref, reactive, onMounted } from "vue";
import { ElMessage } from "element-plus";
import ProduceBomRouteAPI, {
  ProduceBomRoutePageQuery,
} from "@/api/module_produce/bomroute";
import DataBomAPI, { DataBomTable } from "@/api/module_data/bom";
import { DataProjectTable } from "@/api/module_data/project";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import ProduceCraftRouteAPI from "@/api/module_produce/craftroute";
import { convertToTree } from "@/views/module_data/utils";

const tableRef = ref();
const total = ref(0);
const selectIds = ref<number[]>([]);
const selectionRows = ref<any[]>([]);
const loading = ref(false);

// 分页表单
const pageTableData = ref<DataBomTable[]>([]);

// 工艺路线下拉选项
const craftRouteOptions = ref<any[]>([]);

// 项目选择相关
const projectDrawerVisible = ref(false);

// 分页查询参数
type QueryFormData = ProduceBomRoutePageQuery & { parent_code?: string };
const queryFormData = reactive<QueryFormData>({
  page_no: 1,
  page_size: 10,
});

// 加载表格数据
// 全量缓存
const allBoms = ref<DataBomTable[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);

function syncCraftRouteToTree(nodes: any[]) {
  if (!nodes) return;
  nodes.forEach((node: any) => {
    const routeRecord = allBomRoutes.value.find((r: any) => r.bom_id === node.id);
    if (routeRecord) {
      node.craft_route = routeRecord.route;
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
        bom.craft_route = routeRecord.route;
      }
    });

    let displayNodes = [];
    if (selectedRootBomCode.value) {
      displayNodes = collectSubtreeByRootCode(allBoms.value as any[], selectedRootBomCode.value);
    } else {
      displayNodes = allBoms.value;
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

// 查询（重置页码后获取数据）
async function handleQuery() {
  queryFormData.page_no = 1;
  loadingData();
}

async function ensureAllBomsLoaded() {
  if (allBoms.value.length > 0) return;
  const res = await DataBomAPI.listDataBomNoProcure();
  allBoms.value = res.data.data || [];
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

// 加载工艺路线下拉选项
async function loadCraftRouteOptions() {
  try {
    const response = await ProduceCraftRouteAPI.getAllProduceCraftRoute();
    craftRouteOptions.value = response.data.data || [];
  } catch (error: any) {
    console.error(error);
  }
}

// 工艺路线明细缓存
const routeCraftsCache = new Map<number, number[]>();

async function getRouteCrafts(routeCode: number): Promise<number[]> {
  if (!routeCode) return [];
  if (routeCraftsCache.has(routeCode)) return routeCraftsCache.get(routeCode)!;

  try {
    const res = await ProduceCraftRouteAPI.detailProduceCraftRoute(routeCode);
    const items = res.data?.data?.items || [];
    const craftIds = items.map((i: any) => Number(i.craft_id)).filter((id: number) => id > 0);
    routeCraftsCache.set(routeCode, craftIds);
    return craftIds;
  } catch (error) {
    console.error(`Failed to fetch crafts for route ${routeCode}:`, error);
    return [];
  }
}

function isSubset(subset: number[], superset: number[]): boolean {
  return subset.every((id) => superset.includes(id));
}

// 获取所有祖先节点
function getAllAncestors(node: any, allNodes: any[]): any[] {
  const ancestors: any[] = [];
  let currentParentCode = node.parent_code;
  while (currentParentCode) {
    const parent = allNodes.find((n) => n.code === currentParentCode);
    if (parent) {
      ancestors.push(parent);
      currentParentCode = parent.parent_code;
    } else {
      break;
    }
  }
  return ancestors;
}

// 获取所有后代节点
function getAllDescendants(node: any, allNodes: any[]): any[] {
  const descendants: any[] = [];
  const children = allNodes.filter((n) => n.parent_code === node.code);
  for (const child of children) {
    descendants.push(child);
    descendants.push(...getAllDescendants(child, allNodes));
  }
  return descendants;
}

function updateTreeCraftRouteById(nodes: any[], bomId: number, craftRoute: any): boolean {
  for (const node of nodes || []) {
    if (node.id === bomId) {
      node.craft_route = craftRoute;
      return true;
    }
    if (node.children && node.children.length > 0) {
      const updated = updateTreeCraftRouteById(node.children, bomId, craftRoute);
      if (updated) return true;
    }
  }
  return false;
}

// 工艺路线变更处理（仅更新表格数据，不保存数据库）
function handleCraftRouteChange(row: any) {
  const craftRoute = row.craft_route;
  const bom = (allBoms.value as any[]).find((item: any) => item.id === row.id);
  if (bom) {
    bom.craft_route = craftRoute;
  }
  if (row.id) {
    updateTreeCraftRouteById(pageTableData.value as any[], row.id, craftRoute);
  }

  if (!row.id || !selectIds.value.includes(row.id)) return;

  (selectionRows.value as any[]).forEach((selectedRow: any) => {
    if (!selectedRow?.id || selectedRow.id === row.id) return;
    selectedRow.craft_route = craftRoute;
    const selectedBom = (allBoms.value as any[]).find((item: any) => item.id === selectedRow.id);
    if (selectedBom) {
      selectedBom.craft_route = craftRoute;
    }
    updateTreeCraftRouteById(pageTableData.value as any[], selectedRow.id, craftRoute);
  });
}

// 批量保存工艺路线到数据库
async function handleBatchSaveCraftRoute() {
  try {
    if (!selectedRootBomCode.value) {
      ElMessage.warning("请先选择项目或BOM");
      return;
    }

    // 1. 获取当前显示的所有节点
    const targetNodes = collectSubtreeByRootCode(allBoms.value as any[], selectedRootBomCode.value);
    if (targetNodes.length === 0) {
      ElMessage.warning("暂无数据可保存");
      return;
    }

    loading.value = true;

    // 2. 收集所有涉及到的工艺路线代码（用于校验）
    const relevantRoutes = new Set<number>();
    targetNodes.forEach((node: any) => {
      if (node.craft_route) relevantRoutes.add(Number(node.craft_route));

      // 收集所有祖先和后代的工艺路线
      const ancestors = getAllAncestors(node, allBoms.value);
      ancestors.forEach((a) => {
        if (a.craft_route) relevantRoutes.add(Number(a.craft_route));
      });
      const descendants = getAllDescendants(node, allBoms.value);
      descendants.forEach((d) => {
        if (d.craft_route) relevantRoutes.add(Number(d.craft_route));
      });
    });

    // 3. 预取所有涉及到的工艺路线明细（并行请求以提高效率）
    await Promise.all(Array.from(relevantRoutes).map((r) => getRouteCrafts(r)));

    // 4. 执行校验逻辑
    for (const node of targetNodes) {
      const nodeRoute = Number(node.craft_route || 0);
      const nodeCrafts = await getRouteCrafts(nodeRoute);

      // 规则 A：递归校验所有父节点是否涵盖当前节点的工艺路线
      const ancestors = getAllAncestors(node, allBoms.value);
      for (const ancestor of ancestors) {
        const ancestorRoute = Number(ancestor.craft_route || 0);
        if (ancestorRoute) {
          const ancestorCrafts = await getRouteCrafts(ancestorRoute);
          if (!isSubset(nodeCrafts, ancestorCrafts)) {
            ElMessage.error(
              `校验失败：父节点 [${ancestor.id}] 工艺路线未包含子节点 [${node.id}]`
            );
            loading.value = false;
            return;
          }
        } else if (nodeRoute > 0) {
          // 如果子节点有工艺但父节点没设
          ElMessage.error(`校验失败：父节点 [${ancestor.id}] 未设置工艺路线，无法包含子节点`);
          loading.value = false;
          return;
        }
      }

      // 规则 B：递归校验所有子节点是否被当前节点的工艺路线包含
      const descendants = getAllDescendants(node, allBoms.value);
      for (const descendant of descendants) {
        const descendantRoute = Number(descendant.craft_route || 0);
        if (descendantRoute) {
          const descendantCrafts = await getRouteCrafts(descendantRoute);
          if (!isSubset(descendantCrafts, nodeCrafts)) {
            ElMessage.error(
              `校验失败：子节点 [${descendant.id}] 工艺路线未被父节点 [${node.id}] 包含`
            );
            loading.value = false;
            return;
          }
        }
      }
    }

    // 5. 收集所有发生变化的节点（不论是否勾选，去掉自动包含祖先的逻辑）
    const data: { bom_id: number; route: number }[] = [];
    targetNodes.forEach((node: any) => {
      const bomId = node.id;
      const currentRoute = node.craft_route;
      // 从原始数据中查找旧的工艺路线
      const originalRecord = allBomRoutes.value.find((r: any) => r.bom_id === bomId);
      const originalRoute = originalRecord ? originalRecord.route : undefined;

      // 如果当前路线与原始路线不同，则需要保存
      if (currentRoute !== originalRoute) {
        data.push({
          bom_id: bomId,
          route: currentRoute,
        });
      }
    });

    if (data.length === 0) {
      ElMessage.info("数据未发生变化，无需保存");
      loading.value = false;
      return;
    }

    await ProduceBomRouteAPI.upsertBatchProduceBomRoute(data);

    // 6. 保存成功后，更新本地缓存的原始数据
    data.forEach((item) => {
      const existing = allBomRoutes.value.find((r: any) => r.bom_id === item.bom_id);
      if (existing) {
        existing.route = item.route;
      } else {
        allBomRoutes.value.push({ bom_id: item.bom_id, route: item.route });
      }
    });

    ElMessage.success(`保存成功，共更新 ${data.length} 条记录`);
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

// 行复选框选中项变化
async function handleSelectionChange(selection: any) {
  selectIds.value = selection.map((item: any) => item.id);
  selectionRows.value = selection;
}

onMounted(async () => {
  await loadCraftRouteOptions();
  pageTableData.value = [];
});
</script>

<style lang="scss" scoped></style>
