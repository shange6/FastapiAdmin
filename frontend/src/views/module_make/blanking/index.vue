<template>
  <div class="app-container">
    <el-card class="data-table">
      <template #header>
        <div class="flex-x-between">
          <div class="flex-x-start">
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
      ><template #empty>
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
        <el-table-column label="工艺" min-width="70" align="center">
          <template #default="{ row }">
            <el-tag>{{ TARGET_CRAFT_NAME }}</el-tag>
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
      :show_dai="blankingCraftId"
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
        <el-descriptions-item label="BOMID">{{ activeRow.bom_id }}</el-descriptions-item>
        <el-descriptions-item label="代号">{{ activeRow.code }}</el-descriptions-item>        
        <el-descriptions-item label="数量">{{ activeRow.count }}</el-descriptions-item>
        <el-descriptions-item label="单重">{{ activeRow.unit_mass }}</el-descriptions-item>
        <el-descriptions-item label="工序ID">{{ activeRow.make_id }}</el-descriptions-item>
        <el-descriptions-item label="总重">{{ activeRow.total_mass }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ activeRow.remark }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import ProduceMakeAPI from "@/api/module_make/blanking";
import ProduceCraftAPI from "@/api/module_produce/craft";
import ProjectSelectDrawer from "@/views/module_data/ProjectSelectDrawer.vue";
import { convertToTree } from "@/views/module_data/utils";
import { useUserStore } from "@/store/modules/user.store";

// --- 状态定义 ---
const userStore = useUserStore();
const tableRef = ref();
const loading = ref(false);
const projectDrawerVisible = ref(false);
const detailVisible = ref(false);
const selectionRows = ref<any[]>([]);
const pageTableData = ref<any[]>([]);
const activeRow = ref<any>({});

const craftMap = new Map<number, string>();
const allBoms = ref<any[]>([]);
const selectedProjectCode = ref("");
const TARGET_CRAFT_NAME = "下料"; // 统一管理处
const blankingCraftId = ref<number>();

async function initBaseData() {
  const res = await ProduceCraftAPI.getAllProduceCraft();
  res.data.data?.forEach((c: any) => {
    craftMap.set(c.id, c.name);
    // 自动寻找匹配名称的 ID
    if (c.name === TARGET_CRAFT_NAME) {
      blankingCraftId.value = c.id;
    }
  });
}

// 同步业务数据（简化版：一次 Map 循环解决）
async function refreshData() {
  if (!selectedProjectCode.value) return;
  loading.value = true;
  try {
    // 1. 获取该项目的所有制造进度记录
    const makeRes = await ProduceMakeAPI.listProduceMake({ project_code: selectedProjectCode.value });
    const makeMap = new Map(makeRes.data.data.items.map((m: any) => [Number(m.bom_id), m]));

    // 2. 将进度填充到 BOM 扁平数据中
    const processedBoms = allBoms.value.map(bom => {
      const make = makeMap.get(Number(bom.id));
      return make ? { ...bom, ...make, make_id: make.id, id: bom.id } : bom;
    });

    // 3. 过滤并构建树（只显示属于“下料”工序的零件）
    const { tree } = convertToTree(
      processedBoms.filter(b => b.current_craft_id === blankingCraftId.value),
      undefined,
      allBoms.value[0]?.first_code // 根节点代码
    );
    pageTableData.value = tree;
  } catch (e) {
    ElMessage.error("数据加载失败");
  } finally {
    loading.value = false;
  }
}

// 选择项目回调
function handleSelectProject(project: any) {
  selectedProjectCode.value = project.code;
  allBoms.value = project.recursive_data;
  projectDrawerVisible.value = false;
  refreshData();
}

// 提交工序核心方法
async function submitProcess(rows: any[]) {
  const validRows = rows.filter(r => r.make_id);
  if (validRows.length === 0) return ElMessage.warning("选中行无进度信息");

  const submitAction = async () => {
    loading.value = true;
    for (const row of validRows) {
      await ProduceMakeAPI.submitProduceMakeFlow({
        make_id: row.make_id,
        bom_id: Number(row.id),
        user_id: userStore.basicInfo.id!,
        sort: row.current_sort,
        craft_id: row.current_craft_id,
        end_time: new Date().toISOString()
      });
    }
    ElMessage.success("操作成功");
    refreshData();
  };

  ElMessageBox.confirm(`确定提交选中的 ${validRows.length} 条记录吗？`, "提示", { type: "warning" })
    .then(submitAction)
    .catch(() => {});
}

// --- 交互方法 ---
const submitFlow = (row: any) => submitProcess([row]);
const handleBatchSubmit = () => submitProcess(selectionRows.value);

const showDetail = (row: any) => {
  activeRow.value = row;
  detailVisible.value = true;
};

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