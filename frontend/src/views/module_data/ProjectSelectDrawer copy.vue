<template>
  <el-drawer
    v-model="isVisible"
    title="选择项目"
    direction="rtl"
    size="40%"
    @close="handleClose"
  >
    <div class="project-drawer-content" v-loading="projectLoading">
      <el-input
        v-model="projectSearch"
        placeholder="搜索项目名称、代号或合同编号"
        prefix-icon="Search"
        clearable
        class="mb-4"
        @input="handleProjectSearch"
      />
      
      <el-table
        :data="projectList"
        border
        stripe
        :height="tableHeight"
        style="width: 100%"
        :highlight-current-row="!showBomTable"
        @row-click="handleSelectProject"
        @cell-mouse-enter="handleProjectMouseEnter"
        @cell-mouse-leave="handleProjectMouseLeave"
      >
        <el-table-column
          v-if="isDaiColumnVisible"
          prop="dai_count"
          label="待"
          min-width="50"
          align="center"
          show-overflow-tooltip
        >
          <template #default="{ row }">
            <span :style="{ color: row.dai_count > 0 ? 'red' : 'green', fontWeight: 'bold' }">
              {{ row.dai_count }}
            </span>
          </template>
        </el-table-column>

        <el-table-column prop="code" label="项目代号" min-width="120" align="center" show-overflow-tooltip />
        <el-table-column prop="name" label="项目名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="no" label="合同编号" min-width="100" align="center" show-overflow-tooltip />
      </el-table>
    </div>

    <Transition name="el-fade-in">
      <div 
        v-show="projectHover.visible" 
        class="project-hover-panel" 
        @mouseenter="projectHover.locked = true" 
        @mouseleave="handleProjectHoverPanelLeave" 
      > 
        <div v-if="projectHover.loading" class="loading-wrapper">
          <el-skeleton :rows="8" animated /> 
        </div>
        <el-empty v-else-if="projectHover.children.length === 0" description="无数据" :image-size="60" /> 
        <el-table 
          v-else 
          :data="projectHover.children" 
          border 
          stripe 
          height="100%"
          :style="{ width: (showOrderColumn ? '480px' : '380px') }"
          highlight-current-row 
          @row-click="handleHoverBomRowClick" 
        > 
          <el-table-column v-if="isDaiColumnVisible" prop="dai_count" label="待" width="50" align="center">
            <template #default="{ row }">
              <span :style="{ color: row.dai_count > 0 ? 'red' : 'green' }">{{ row.dai_count }}</span>
            </template>
          </el-table-column>
          <el-table-column v-if="showOrderColumn" prop="no" label="单号" width="100" align="center" show-overflow-tooltip /> 
          <el-table-column prop="code" label="代号" width="140" align="center" show-overflow-tooltip /> 
          <el-table-column prop="spec" label="名称" min-width="150" show-overflow-tooltip /> 
        </el-table> 
      </div> 
    </Transition>

    <template #footer>
      <div class="flex justify-end">
        <pagination
          v-model:total="projectTotal"
          v-model:page="projectQuery.page_no"
          v-model:limit="projectQuery.page_size"
          @pagination="fetchProjects(false)"
        />
      </div>
    </template>
  </el-drawer>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted, computed, onUnmounted } from "vue";
import { useDebounceFn, useWindowSize } from "@vueuse/core";
import { ElMessage } from "element-plus";
import DataProjectAPI, { DataProjectTable } from "@/api/module_data/project";
import DataBomAPI, { DataBomTable } from "@/api/module_data/bom";
import ProduceOrderAPI from "@/api/module_produce/order";
import ProduceMakeAPI from "@/api/module_make/blanking";

interface Props {
  modelValue: boolean;
  showBomTable?: boolean;
  showOrderColumn?: boolean;
  show_dai?: boolean | number;
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: false,
  showBomTable: false,
  showOrderColumn: false,
  show_dai: false,
});

const emit = defineEmits(["update:modelValue", "select"]);

const isVisible = computed({
  get: () => props.modelValue,
  set: (val) => emit("update:modelValue", val),
});

const isDaiColumnVisible = computed(() => props.show_dai !== false && props.show_dai !== 0);
const { height: windowHeight } = useWindowSize();
const tableHeight = computed(() => `${windowHeight.value - 220}px`);

const projectLoading = ref(false);
const allProjects = ref<DataProjectTable[]>([]);
const projectList = ref<DataProjectTable[]>([]);
const projectTotal = ref(0);
const projectSearch = ref("");

const projectQuery = reactive({
  page_no: 1,
  page_size: 20,
});

const projectHover = reactive({
  visible: false,
  loading: false,
  locked: false,
  children: [] as DataBomTable[],
  currentProjectCode: "",
});

let hoverTimer: any = null;
let abortController: AbortController | null = null;

const calculatePageSize = () => {
  const size = Math.floor((windowHeight.value - 260) / 40);
  return size > 5 ? size : 15;
};

async function fetchProjects(force = false) {
  projectLoading.value = true;
  try {
    if (allProjects.value.length === 0 || force) {
      const params: any = isDaiColumnVisible.value ? { show_dai: Number(props.show_dai) } : {};
      const response = await DataProjectAPI.getAllDataProject(params);
      allProjects.value = response.data.data || [];
    }
    const keyword = projectSearch.value?.toLowerCase().trim();
    const filtered = allProjects.value.filter(item => 
      !keyword || item.code?.toLowerCase().includes(keyword) || 
      item.name?.toLowerCase().includes(keyword) || item.no?.toLowerCase().includes(keyword)
    );
    projectTotal.value = filtered.length;
    const start = (projectQuery.page_no - 1) * projectQuery.page_size;
    projectList.value = filtered.slice(start, start + projectQuery.page_size);
  } catch (error) {
    ElMessage.error("获取项目列表失败");
  } finally {
    projectLoading.value = false;
  }
}

async function loadBomPreviewData(row: DataProjectTable) {
  if (abortController) abortController.abort();
  abortController = new AbortController();
  projectHover.loading = true;
  projectHover.children = [];
  try {
    const res = await DataBomAPI.listProjectBoms(row.code || "");
    const boms = (res.data.data || []).slice(0, 100);

    if (props.showOrderColumn && boms.length > 0) {
      const bomIds = boms.map(b => Number(b.id)).filter(id => id > 0);
      // 后端 summary_batch 接口应返回空msg以实现静默
      const orderRes = await ProduceOrderAPI.summaryBatchProduceOrder({ bom_ids: bomIds });
      const orderMap = orderRes.data?.data || {};
      boms.forEach(b => { if (b.id) b.no = orderMap[String(b.id)] || ""; });

      if (isDaiColumnVisible.value) {
        const orderNos = boms.map(b => b.no).filter(Boolean) as string[];
        if (orderNos.length > 0) {
          const craftId = typeof props.show_dai === "number" ? props.show_dai : 1;
          const daiRes = await ProduceMakeAPI.summaryProduceMakeByOrders(orderNos, craftId);
          const daiMap = daiRes.data?.data || {};
          boms.forEach(b => { if (b.no) b.dai_count = daiMap[b.no] || 0; });
        }
      }
    }
    projectHover.children = boms;
  } catch (error: any) {
    if (error.name !== 'AbortError') console.error(error);
  } finally {
    projectHover.loading = false;
  }
}

function handleProjectMouseEnter(row: DataProjectTable) {
  if (!props.showBomTable || projectHover.locked) return;

  // 如果已经在该行显示，直接清除之前的关闭定时器并返回
  if (projectHover.visible && projectHover.currentProjectCode === row.code) {
    if (hoverTimer) clearTimeout(hoverTimer);
    return;
  }

  // 换行逻辑
  if (hoverTimer) clearTimeout(hoverTimer);
  if (abortController) abortController.abort();

  hoverTimer = setTimeout(() => {
    projectHover.visible = true;
    projectHover.currentProjectCode = row.code || "";
    loadBomPreviewData(row);
    hoverTimer = null;
  }, 450);
}

function handleProjectMouseLeave(row: DataProjectTable) {
  // 鼠标移动到同行其他单元格时，由于 handleProjectMouseEnter 会拦截，此处的关闭定时器应被清除
  if (hoverTimer) clearTimeout(hoverTimer);
  
  hoverTimer = setTimeout(() => {
    if (!projectHover.locked) {
      projectHover.visible = false;
      // 只有在确定不显示时才清空 ID，确保跨列移动时的“同一行”判断有效
      if (!projectHover.visible) {
        projectHover.currentProjectCode = "";
      }
      if (abortController) abortController.abort();
    }
  }, 200);
}

function handleProjectHoverPanelLeave() {
  projectHover.locked = false;
  projectHover.visible = false;
  projectHover.currentProjectCode = "";
  if (abortController) abortController.abort();
}

async function handleHoverBomRowClick(row: DataBomTable) {
  // 解决 string | undefined 校验报错
  if (!row.code) return; 
  
  projectLoading.value = true;
  try {
    const res = await DataBomAPI.listRecursiveBoms(row.code, row.first_code);
    emit("select", {
      ...allProjects.value.find(p => p.code === projectHover.currentProjectCode),
      root_bom_code: row.code,
      parent_code: row.parent_code,
      recursive_data: res.data.data || []
    });
    isVisible.value = false;
    handleProjectHoverPanelLeave();
  } catch (error) {
    ElMessage.error("获取详细清单失败");
  } finally {
    projectLoading.value = false;
  }
}

const handleProjectSearch = useDebounceFn(() => {
  projectQuery.page_no = 1;
  fetchProjects();
}, 300);

function handleSelectProject(project: DataProjectTable) {
  if (props.showBomTable) return;
  emit("select", project);
  isVisible.value = false;
}

function handleClose() {
  if (hoverTimer) clearTimeout(hoverTimer);
  if (abortController) abortController.abort();
  isVisible.value = false;
  projectHover.visible = false;
  projectHover.currentProjectCode = "";
}

watch(isVisible, (val) => {
  if (val) {
    projectQuery.page_size = calculatePageSize();
    fetchProjects(true);
  }
});

onUnmounted(() => {
  if (hoverTimer) clearTimeout(hoverTimer);
  if (abortController) abortController.abort();
});
</script>

<style lang="scss" scoped>
.project-drawer-content {
  padding: 0 4px;
}

.project-hover-panel { 
  position: fixed; 
  // 垂直位置与表格起始对齐 (Drawer标题+搜索框高度)
  top: 130px; 
  // 底部位置留出分页器空间
  bottom: 80px;
  // 固定在抽屉左侧 (40%宽度 + 间距)
  right: calc(40% + 15px); 
  z-index: 3000; 
  background: var(--el-bg-color); 
  border: 1px solid var(--el-border-color-light); 
  border-radius: 8px; 
  box-shadow: var(--el-box-shadow-dark); 
  padding: 8px;
  display: flex;
  flex-direction: column;

  .loading-wrapper {
    width: 100%;
    padding: 15px;
  }

  // 确保内部表格撑满并滚动
  :deep(.el-table) {
    flex: 1;
  }
} 

:deep(.el-table) {
  --el-table-header-bg-color: var(--el-fill-color-light);
}

.flex { display: flex; }
.justify-end { justify-content: flex-end; }
.mb-4 { margin-bottom: 1rem; }
</style>