<template>
  <div class="app-container">
    <el-card class="data-table">
      <template #header>
        <div class="flex-x-between">
          <div class="flex-x-start">
            <span class="text-lg font-bold mr-4">{{ targetCraftName }}管理</span>
            <el-button type="info" plain icon="Expand" @click="toggleExpansion(true)">展开</el-button>
            <el-button type="info" plain icon="Fold" @click="toggleExpansion(false)">收起</el-button>
          </div>
          <div class="flex-x-end">
            <el-button type="warning" icon="FolderChecked" @click="handleBatchSubmit">提交</el-button>
            <el-button type="primary" icon="Collection" @click="projectDrawerVisible = true">项目</el-button>
          </div>
        </div>
      </template>

      <el-table
        ref="tableRef"
        v-loading="loading"
        :data="pageTableData"
        row-key="id"
        border
        stripe
        @selection-change="(val) => (selectionRows = val)"
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column type="selection" min-width="40" align="center" />
        <el-table-column label="代号" prop="code" min-width="260" header-align="center" show-overflow-tooltip fixed="left" />
        <el-table-column label="名称" prop="spec" min-width="160" header-align="center" show-overflow-tooltip fixed="left" />
        <el-table-column label="数量" prop="count" min-width="60" align="center" />
        <el-table-column label="材质" prop="material" min-width="100" header-align="center" show-overflow-tooltip />
        <el-table-column label="备注" prop="remark" min-width="100" header-align="center" show-overflow-tooltip />
        <el-table-column label="工艺" min-width="70" align="center">
          <template #default>
            <el-tag>{{ targetCraftName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="120" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="info" link @click="showDetail(row)">详情</el-button>
            <el-button type="primary" link @click="submitFlow(row)">提交</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <ProjectSelectDrawer 
      v-model="projectDrawerVisible" 
      :show-bom-table="true"
      :show-order-column="true"
      :show_dai="currentCraftId"
      @select="handleSelectProject" 
      logicType="production"
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

    <el-dialog v-model="detailVisible" title="工序详情" width="600px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="项目代号">{{ activeRow.project_code }}</el-descriptions-item>
        <el-descriptions-item label="工单">{{ activeRow.order_no }}</el-descriptions-item>
        <el-descriptions-item label="根代号">{{ activeRow.first_code }}</el-descriptions-item>
        <el-descriptions-item label="数量">{{ activeRow.count }}</el-descriptions-item>
        <el-descriptions-item label="代号">{{ activeRow.code }}</el-descriptions-item>   
        <el-descriptions-item label="单重">{{ activeRow.unit_mass }}</el-descriptions-item>
        <el-descriptions-item label="BOMID">{{ activeRow.id }}</el-descriptions-item>
        <el-descriptions-item label="总重">{{ activeRow.total_mass }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ activeRow.remark }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import ProduceMakeAPI from "@/api/module_make/blanking";
import ProduceCraftAPI from "@/api/module_produce/craft";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import { convertToTree } from "@/views/module_data/utils";
import { useUserStore } from "@/store/modules/user.store";

const props = defineProps<{
  targetCraftName: string;
}>();

const userStore = useUserStore();
const tableRef = ref();
const loading = ref(false);
const projectDrawerVisible = ref(false);
const detailVisible = ref(false);
const selectionRows = ref<any[]>([]);
const pageTableData = ref<any[]>([]);
const activeRow = ref<any>({});
const currentCraftId = ref<number>();
const allBoms = ref<any[]>([]);
const selectedProjectCode = ref("");

// 初始化工艺基础数据
async function initBaseData() {
  const res = await ProduceCraftAPI.getAllProduceCraft();
  const target = res.data.data?.find((c: any) => c.name === props.targetCraftName);
  if (target) {
    currentCraftId.value = target.id;
  }
}

// 刷新并构建树形数据
async function refreshData() {
  if (!selectedProjectCode.value || !currentCraftId.value) return;
  loading.value = true;
  try {
    const makeRes = await ProduceMakeAPI.listProduceMake({ project_code: selectedProjectCode.value });
    const makeMap = new Map(makeRes.data.data.items.map((m: any) => [Number(m.bom_id), m]));

    const processedBoms = allBoms.value.map(bom => {
      const make = makeMap.get(Number(bom.id));
      return make ? { ...bom, ...make, make_id: make.id, id: bom.id } : bom;
    });

    const { tree } = convertToTree(
      processedBoms.filter(b => b.current_craft_id === currentCraftId.value),
      undefined,
      allBoms.value[0]?.first_code
    );
    pageTableData.value = tree;
  } catch (e) {
    ElMessage.error("数据加载失败");
  } finally {
    loading.value = false;
  }
}

function handleSelectProject(project: any) {
  selectedProjectCode.value = project.code;
  allBoms.value = project.recursive_data;
  projectDrawerVisible.value = false;
  refreshData();
}

async function submitProcess(rows: any[]) {
  const validRows = rows.filter(r => r.make_id);
  if (validRows.length === 0) return ElMessage.warning("选中行无进度信息");

  ElMessageBox.confirm(`确定提交选中的 ${validRows.length} 条记录吗？`, "提示", { type: "warning" })
    .then(async () => {
      loading.value = true;
      try {
        const items = validRows.map(row => ({
          make_id: row.make_id,
          bom_id: Number(row.id),
          user_id: userStore.basicInfo.id!,
          sort: row.current_sort,
          craft_id: row.current_craft_id,
          end_time: new Date().toISOString()
        }));
        
        await ProduceMakeAPI.batchSubmitProduceMakeFlow({ items });
        ElMessage.success("操作成功");
        refreshData();
      } catch (e) {
        ElMessage.error("批量提交失败");
      } finally {
        loading.value = false;
      }
    }).catch(() => {});
}

const showDetail = (row: any) => {
  activeRow.value = row;
  detailVisible.value = true;
};

const submitFlow = (row: any) => submitProcess([row]);
const handleBatchSubmit = () => submitProcess(selectionRows.value);

const toggleExpansion = (exp: boolean) => {
  const traverse = (data: any[]) => {
    data.forEach(n => {
      tableRef.value.toggleRowExpansion(n, exp);
      if (n.children) traverse(n.children);
    });
  };
  traverse(pageTableData.value);
};

onMounted(initBaseData);
</script>