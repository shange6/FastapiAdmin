<!-- BOM路线关联 -->
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
          fixed="right"
          label="ID"
          prop="id"
          min-width="70"
          align="center"
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
    <ProjectSelectDrawer 
      v-model="projectDrawerVisible" 
      :show-bom-table="true"
      @select="handleSelectProject" 
    />
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
import { DataBomTable } from "@/api/module_data/bom";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import ProduceCraftRouteAPI, { CraftRouteView } from "@/api/module_produce/craftroute";
import { convertToTree } from "@/views/module_data/utils";

const tableRef = ref();
const selectIds = ref<number[]>([]);
const selectionRows = ref<any[]>([]);
const loading = ref(false);

// 扩展 DataBomTable 类型，包含工艺路线字段
interface DataBomWithRoute extends DataBomTable {
  craft_route?: number;
}

// 分页表单
const pageTableData = ref<DataBomWithRoute[]>([]);

// 工艺路线下拉选项
const craftRouteOptions = ref<CraftRouteView[]>([]);

// 项目选择相关
const projectDrawerVisible = ref(false);

// 分页查询参数
type QueryFormData = ProduceBomRoutePageQuery & { 
  parent_code?: string;
};
const queryFormData = reactive<QueryFormData>({
  page_no: 1,
  page_size: 10,
});

// 加载表格数据
// 全量缓存
const allBoms = ref<DataBomWithRoute[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);

function syncCraftRouteToFullList() {
  if (!allBoms.value || allBoms.value.length === 0) return;
  
  // 建立 route 映射 Map，用于快速查找
  const routeMap = new Map(allBomRoutes.value.map(r => [r.bom_id, r.route]));

  // 直接在扁平列表上同步数据，这样后续生成的树也会带上这些值
  allBoms.value.forEach((node) => {
    const route = routeMap.get(node.id);
    if (route !== undefined) {
      node.craft_route = route;
    }
  });
}

async function ensureAllBomRoutesLoaded() {
  if (allBomRoutes.value.length > 0) return;
  const routeRes = await ProduceBomRouteAPI.getAllProduceBomRoute();
  allBomRoutes.value = routeRes.data.data || [];
}

async function loadingData() {
  if (!selectedRootBomCode.value && !queryFormData.parent_code) {
    pageTableData.value = [];
    return;
  }

  ElMessage.info("正在更新数据... ...请稍后");
  loading.value = true;
  try {
    await ensureAllBomRoutesLoaded();
    
    // 1. 同步工艺路线到扁平列表 (源数据同步)
    syncCraftRouteToFullList();

    // 2. 直接转换为树形结构，不再进行过滤
    const { tree } = convertToTree(
      allBoms.value, 
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

// 查询（重置页码后获取数据）
async function handleQuery() {
  queryFormData.page_no = 1;
  loadingData();
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
    const response = await ProduceCraftRouteAPI.getCraftRouteViewList({});
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

// 递归遍历树并执行回调
function traverseTree(nodes: any[], callback: (node: any) => void) {
  if (!nodes || nodes.length === 0) return;
  nodes.forEach((node) => {
    callback(node);
    if (node.children && node.children.length > 0) {
      traverseTree(node.children, callback);
    }
  });
}

// 获取树节点 ID 映射 Map
function getTreeNodesMap(nodes: any[]) {
  const map = new Map<number, any>();
  traverseTree(nodes, (node) => {
    if (node.id) map.set(node.id, node);
  });
  return map;
}

// 工艺路线变更处理（仅更新表格数据，不保存数据库）
function handleCraftRouteChange(row: any) {
  const craftRoute = row.craft_route;
  
  // 1. 建立 ID 映射 Map，用于全量数据和树形数据的快速访问
  const bomMap = new Map(allBoms.value.map(item => [item.id, item]));
  const treeMap = getTreeNodesMap(pageTableData.value);

  // 2. 更新当前行及其在全量列表中的映射
  const targetFull = bomMap.get(row.id);
  if (targetFull) targetFull.craft_route = craftRoute;
  
  const targetTree = treeMap.get(row.id);
  if (targetTree) targetTree.craft_route = craftRoute;

  // 3. 批量更新勾选项
  if (!row.id || !selectIds.value.includes(row.id)) return;

  selectionRows.value.forEach((selectedRow) => {
    if (!selectedRow?.id || selectedRow.id === row.id) return;
    
    // 更新全量列表映射
    const bomInFullList = bomMap.get(selectedRow.id);
    if (bomInFullList) bomInFullList.craft_route = craftRoute;
    
    // 更新树形数据映射
    const bomInTree = treeMap.get(selectedRow.id);
    if (bomInTree) bomInTree.craft_route = craftRoute;
    
    // 更新勾选行引用（Vue 响应式）
    selectedRow.craft_route = craftRoute;
  });
}

// 批量保存工艺路线到数据库
async function handleBatchSaveCraftRoute() {
  try {
    if (!selectedRootBomCode.value) {
      ElMessage.warning("请先选择项目或BOM");
      return;
    }

    const targetNodes = allBoms.value;
    if (targetNodes.length === 0) {
      ElMessage.warning("暂无数据可保存");
      return;
    }

    loading.value = true;

    // 1. 建立索引 Map 以加速访问
    const bomMapByCode = new Map<string, any>();
    const childrenMap = new Map<string, any[]>();
    targetNodes.forEach(node => {
      if (node.code) {
        bomMapByCode.set(node.code, node);
        if (node.parent_code) {
          if (!childrenMap.has(node.parent_code)) childrenMap.set(node.parent_code, []);
          childrenMap.get(node.parent_code)!.push(node);
        }
      }
    });

    // 2. 收集所有涉及到的工艺路线代码
    const relevantRoutes = new Set<number>();
    targetNodes.forEach((node: any) => {
      if (node.craft_route) relevantRoutes.add(Number(node.craft_route));
    });

    // 3. 预取所有涉及到的工艺路线明细
    await Promise.all(Array.from(relevantRoutes).map((r) => getRouteCrafts(r)));

    // 4. 执行校验逻辑：仅校验父子层级关系，减少冗余计算
    for (const node of targetNodes) {
      const nodeRoute = Number(node.craft_route || 0);
      const nodeCrafts = await getRouteCrafts(nodeRoute);

      // 规则：子节点工艺路线必须是父节点工艺路线的子集
      if (node.parent_code) {
        const parent = bomMapByCode.get(node.parent_code);
        if (parent) {
          const parentRoute = Number(parent.craft_route || 0);
          if (parentRoute) {
            const parentCrafts = await getRouteCrafts(parentRoute);
            if (!isSubset(nodeCrafts, parentCrafts)) {
              ElMessage.error(
                `校验失败：零件 [${node.code}] 的工艺路线未包含在父零件 [${parent.code}] 中`
              );
              loading.value = false;
              return;
            }
          } else if (nodeRoute > 0) {
            // 子节点有工艺但父节点没设（且父节点在本次处理范围内）
            ElMessage.error(`校验失败：父零件 [${parent.code}] 未设置工艺路线，无法包含子零件 [${node.code}]`);
            loading.value = false;
            return;
          }
        }
      }
    }

    // 5. 收集发生变化的节点
    const data: { bom_id: number; route: number }[] = [];
    const originalRouteMap = new Map(allBomRoutes.value.map(r => [r.bom_id, r.route]));

    targetNodes.forEach((node: any) => {
      const currentRoute = node.craft_route;
      const originalRoute = originalRouteMap.get(node.id);

      if (currentRoute !== originalRoute) {
        data.push({
          bom_id: node.id,
          route: currentRoute,
        });
      }
    });
    
    if (data.length === 0) {
      ElMessage.info("数据未发生变化，无需保存");
      loading.value = false;
      return;
    }

    const res = await ProduceBomRouteAPI.upsertBatchProduceBomRoute(data);
    // console.log(res)
    if (res.data.code === 0) {
      // 6. 更新本地缓存
      data.forEach((item) => {
        const existing = allBomRoutes.value.find((r: any) => r.bom_id === item.bom_id);
        if (existing) {
          existing.route = item.route;
        } else {
          allBomRoutes.value.push({ bom_id: item.bom_id, route: item.route });
        }
      });
     }
   } catch (error: any) {
    console.error(error);
    ElMessage.error("保存过程中发生错误，请查看控制台");
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
