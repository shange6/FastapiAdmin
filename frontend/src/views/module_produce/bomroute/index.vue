<template>
  <div class="app-container">
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

      <el-table
        ref="tableRef"
        v-loading="loading"
        :data="pageTableData"
        row-key="id"
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
        <el-table-column fixed="left" label="代号" prop="code" min-width="260" header-align="center" show-overflow-tooltip />
        <el-table-column fixed="left" label="名称" prop="spec" min-width="160" header-align="center" show-overflow-tooltip />
        <el-table-column label="数量" prop="count" min-width="60" align="center" header-align="center" show-overflow-tooltip />
        <el-table-column label="材质" prop="material" min-width="100" header-align="center" show-overflow-tooltip />
        <el-table-column label="单重" prop="unit_mass" min-width="70" align="center" header-align="center" show-overflow-tooltip />
        <el-table-column label="总重" prop="total_mass" min-width="70" align="center" header-align="center" show-overflow-tooltip />
        <el-table-column label="备注" prop="remark" min-width="100" header-align="center" show-overflow-tooltip />
        <el-table-column fixed="right" label="ID" prop="id" min-width="70" align="center" header-align="center" show-overflow-tooltip />
        <el-table-column label="工艺路线" prop="craft_route" min-width="370" align="center" header-align="center" show-overflow-tooltip fixed="right">
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

   <ProjectSelectDrawer 
      v-model="projectDrawerVisible" 
      :show-bom-table="true"
      :show-order-column="false"
      :show_dai="1"
      @select="handleSelectProject" 
      logicType="missroute"
    >
      <template #dai-project>
        <el-table-column prop="dai_project" label="待" width="60" align="center">
          <template #default="{ row }">
            <b :style="{ color: row.dai_project > 0 ? 'red' : 'green' }">{{ row.dai_project }}</b>
          </template>
        </el-table-column>
      </template>

      <template #dai-bom>
        <el-table-column prop="dai_bom" label="待" width="60" align="center">
          <template #default="{ row }">
            <b :style="{ color: row.dai_bom > 0 ? 'red' : 'green' }">{{ row.dai_bom }}</b>
          </template>
        </el-table-column>
      </template>
    </ProjectSelectDrawer>
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

// 1. 在本地扩展接口，确保 ID 明确存在（如果业务保证 ID 一定有）
interface DataBomWithRoute extends DataBomTable {
  id: number; // 强制覆盖 ID 为必填，解决 Map 报错
  craft_route?: number;
}

const pageTableData = ref<DataBomWithRoute[]>([]);
const craftRouteOptions = ref<CraftRouteView[]>([]);
const projectDrawerVisible = ref(false);

const allBoms = ref<DataBomWithRoute[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);
const selectedProjectId = ref<number | undefined>(undefined);
const selectedFirstBomId = ref<number | undefined>(undefined);

const queryFormData = reactive<ProduceBomRoutePageQuery & { parent_code?: string }>({
  page_no: 1,
  page_size: 10,
});

function syncCraftRouteToFullList() {
  if (!allBoms.value || allBoms.value.length === 0) return;
  const routeMap = new Map(allBomRoutes.value.map(r => [r.bom_id, r.route]));

  allBoms.value.forEach((node) => {
    if (node.id) {
      const route = routeMap.get(node.id);
      if (route !== undefined) {
        node.craft_route = route;
      }
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
  ElMessage.info("正在更新数据... ...");
  loading.value = true;
  try {
    await ensureAllBomRoutesLoaded();
    syncCraftRouteToFullList();
    const { tree } = convertToTree(
      allBoms.value, 
      selectedRootBomCode.value ? undefined : queryFormData.parent_code, 
      selectedRootBomCode.value
    );
    pageTableData.value = tree as DataBomWithRoute[];
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

function toggleAllExpansion(expanded: boolean) {
  const toggle = (nodes: any[]) => {
    nodes.forEach((node: any) => {
      tableRef.value?.toggleRowExpansion(node, expanded);
      if (node.children) toggle(node.children);
    });
  };
  toggle(pageTableData.value);
}

function handleOpenProjectDrawer() {
  projectDrawerVisible.value = true;
}

function handleSelectProject(project: any) {
  if (project.recursive_data && project.root_bom_code) {
    queryFormData.parent_code = project.code;
    projectDrawerVisible.value = false;
    selectedRootBomCode.value = project.root_bom_code;
    selectedProjectId.value = project.id;
    selectedFirstBomId.value = project.first_id;
    // 注入数据时进行断言，确保 ID 安全
    allBoms.value = project.recursive_data as DataBomWithRoute[];
    loadingData();
  }
}

async function loadCraftRouteOptions() {
  const response = await ProduceCraftRouteAPI.getCraftRouteViewList({});
  craftRouteOptions.value = response.data.data || [];
}

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
    return [];
  }
}

function traverseTree(nodes: any[], callback: (node: any) => void) {
  nodes.forEach((node) => {
    callback(node);
    if (node.children) traverseTree(node.children, callback);
  });
}

function handleCraftRouteChange(row: DataBomWithRoute) {
  const craftRoute = row.craft_route;
  const bomMap = new Map(allBoms.value.map(item => [item.id, item]));
  
  const targetFull = bomMap.get(row.id);
  if (targetFull) targetFull.craft_route = craftRoute;

  if (!row.id || !selectIds.value.includes(row.id)) return;

  selectionRows.value.forEach((selectedRow) => {
    if (!selectedRow?.id || selectedRow.id === row.id) return;
    const bomInFullList = bomMap.get(selectedRow.id);
    if (bomInFullList) bomInFullList.craft_route = craftRoute;
    selectedRow.craft_route = craftRoute;
  });
}

// 核心修复：批量保存逻辑
async function handleBatchSaveCraftRoute() {
  try {
    if (!selectedRootBomCode.value) {
      ElMessage.warning("请先选择项目或BOM");
      return;
    }

    // 过滤无效数据，确保所有参与校验的 node 都有明确的 id 和 code
    const targetNodes = allBoms.value.filter(n => n.id && n.code);
    if (targetNodes.length === 0) {
      ElMessage.warning("暂无有效数据可保存");
      return;
    }

    loading.value = true;

    // 1. 建立索引 Map (使用类型断言，因为上面已经 filter 过了)
    const bomMapByCode = new Map<string, DataBomWithRoute>(
      targetNodes.map(node => [node.code as string, node])
    );

    // 2. 预取工艺路线明细
    const routeDetailsMap = new Map<number, number[]>();
    const relevantRouteIds = [...new Set(targetNodes.map(n => Number(n.craft_route)).filter(id => id > 0))];
    
    await Promise.all(relevantRouteIds.map(async (routeId) => {
      const crafts = await getRouteCrafts(routeId);
      routeDetailsMap.set(routeId, crafts);
    }));

    // 3. 执行校验逻辑
    for (const node of targetNodes) {
      const nodeRouteId = Number(node.craft_route || 0);
      
      if (nodeRouteId > 0 && node.parent_code) {
        const parent = bomMapByCode.get(node.parent_code);
        if (parent) {
          const parentRouteId = Number(parent.craft_route || 0);
          
          if (parentRouteId === 0) {
            throw new Error(`校验失败：父节点 [${parent.id}] 无工艺路线，子节点 [${node.id}]有`);
          }

          const nodeCrafts = routeDetailsMap.get(nodeRouteId) || [];
          const parentCrafts = routeDetailsMap.get(parentRouteId) || [];
          const parentCraftIdSet = new Set(parentCrafts);
          const isSubset = nodeCrafts.every(id => parentCraftIdSet.has(id));

          if (!isSubset) {
            throw new Error(`校验失败：父节点 [${parent.id}] 工艺路线不涵盖子节点 [${node.id}]`);
          }
        }
      }
    }

   // --- 4. 收集差异并提交 ---
    const originalRouteMap = new Map(allBomRoutes.value.map(r => [r.bom_id, r.route]));

    const dataToUpdate = targetNodes
      .filter(node => {
        // 必须满足两个条件：1. 数据有变化；2. route 必须有值（不为 undefined 或 null）
        const isChanged = node.craft_route !== originalRouteMap.get(node.id);
        const hasRoute = node.craft_route !== undefined && node.craft_route !== null;
        return isChanged && hasRoute;
      })
      .map(node => ({
        bom_id: node.id as number,
        route: node.craft_route as number,
        project_id: selectedProjectId.value,
        first_id: selectedFirstBomId.value,
      }));

    if (dataToUpdate.length === 0) {
      ElMessage.info("数据未发生变化或工艺路线不能为空");
      return;
    }

    // 此时 dataToUpdate 的类型就是 { bom_id: number; route: number; }[]
    const res = await ProduceBomRouteAPI.upsertBatchProduceBomRoute(dataToUpdate);
    
    if (res.data.code === 0) {
      ElMessage.success(res.data.msg || "保存成功");
      const updateMap = new Map(dataToUpdate.map(d => [d.bom_id, d.route]));
      
      allBomRoutes.value.forEach((r: any) => {
        if (updateMap.has(r.bom_id)) {
          r.route = updateMap.get(r.bom_id);
          updateMap.delete(r.bom_id);
        }
      });
      
      updateMap.forEach((route, bom_id) => {
        allBomRoutes.value.push({ bom_id, route });
      });
    }
  } catch (error: any) {
    ElMessage.error(error.message || "保存过程中发生错误");
  } finally {
    loading.value = false;
  }
}

async function handleSelectionChange(selection: any) {
  selectIds.value = selection.map((item: any) => item.id);
  selectionRows.value = selection;
}

onMounted(async () => {
  await loadCraftRouteOptions();
});
</script>