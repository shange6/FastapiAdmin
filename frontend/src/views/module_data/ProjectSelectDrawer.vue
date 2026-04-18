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
        @cell-mouse-enter="handleProjectMouseEnter"
        @cell-mouse-leave="handleProjectMouseLeave"
        @row-click="handleSelectProject"
      >
        <slot v-if="isDaiColumnVisible" name="dai-project"></slot>

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
          border stripe height="100%"
          :style="{ width: (showOrderColumn ? '480px' : '380px') }"
          highlight-current-row 
          @row-click="handleHoverBomRowClick" 
        > 
          <slot v-if="isDaiColumnVisible" name="dai-bom"></slot>

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
import { ref, reactive, watch, computed, onUnmounted } from "vue";
import { useDebounceFn, useWindowSize } from "@vueuse/core";
import { ElMessage } from "element-plus";
import * as DaiService from "./daiService"; // 导入逻辑函数
import DataBomAPI from "@/api/module_data/bom";

interface Props {
  modelValue: boolean;
  showBomTable?: boolean;
  showOrderColumn?: boolean;
  show_dai?: boolean | number;
  logicType?: 'production' | 'quality' | 'missroute' | 'missmanhour' | 'missorder'; // 通过此参数指定逻辑
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: false,
  showBomTable: false,
  showOrderColumn: false,
  show_dai: false,
  logicType: 'production',
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
const allProjects = ref<any[]>([]);
const projectList = ref<any[]>([]);
const projectTotal = ref(0);
const projectSearch = ref("");
const projectQuery = reactive({ page_no: 1, page_size: 20 });

const projectHover = reactive({
  visible: false,
  loading: false,
  locked: false,
  children: [] as any[],
  currentProjectCode: "",
});

let hoverTimer: any = null;
let abortController: AbortController | null = null;

// --- 获取数据的主函数 ---
async function fetchProjects(force = false) {
  projectLoading.value = true;
  try {
    if (allProjects.value.length === 0 || force) {
      const params = isDaiColumnVisible.value ? { show_dai: Number(props.show_dai) } : {};
      
      // 根据父组件传入的参数，调用指定的逻辑函数
      switch (props.logicType) {
        case 'production':
          allProjects.value = await DaiService.getProductionProjectList(params);
          break;
          
        case 'quality':
          allProjects.value = await DaiService.getQualityProjectList(params);
          break;
        
        case 'missroute':
          allProjects.value = await DaiService.getMissingRouteProjectList(params);
          break;
        
        case 'missmanhour':
          allProjects.value = await DaiService.getMissingManhourProjectList(params);
          break;
        
        case 'missorder':
          allProjects.value = await DaiService.getMissingOrderProjectList(params);
          break;
                    
        default:
          // 兜底逻辑：如果没有匹配项，执行默认获取
          allProjects.value = await DaiService.getProductionProjectList({});
          break;
      }
    }
    
    // 渲染过滤与分页
    const keyword = projectSearch.value?.toLowerCase().trim();
    const filtered = allProjects.value.filter(item => 
      !keyword || item.code?.toLowerCase().includes(keyword) || 
      item.name?.toLowerCase().includes(keyword) || item.no?.toLowerCase().includes(keyword)
    );
    projectTotal.value = filtered.length;
    projectList.value = filtered.slice((projectQuery.page_no - 1) * projectQuery.page_size, projectQuery.page_no * projectQuery.page_size);
  } finally {
    projectLoading.value = false;
  }
}

async function loadBomPreviewData(row: any) {
  if (abortController) abortController.abort();
  abortController = new AbortController();
  projectHover.loading = true;
  try {
    const craftId = typeof props.show_dai === "number" ? props.show_dai : 1;

    // 根据参数指定调用的函数
    switch (props.logicType) {
      case 'production':
        projectHover.children = await DaiService.getProductionBomPreview(row.code, !!props.showOrderColumn, craftId);
        break;
      case 'missroute':
        projectHover.children = await DaiService.getMissingRouteBomPreview(row.code);
        break;
      case 'missmanhour':
        projectHover.children = await DaiService.getMissingManhourBomPreview(row.code);
        break;
      case 'missorder':
        projectHover.children = await DaiService.getMissingOrderBomPreview(row.code);
        break;
      case 'quality':
        // 预留质量逻辑位置
        break;
      default:
        // 兜底执行默认生产逻辑
        projectHover.children = await DaiService.getProductionBomPreview(row.code, !!props.showOrderColumn, craftId);
        break;
    }
    
  } catch (e: any) {
    if (e.name !== 'AbortError') console.error(e);
  } finally {
    projectHover.loading = false;
  }
}

// 鼠标悬停控制
function handleProjectMouseEnter(row: any) {
  if (!props.showBomTable || projectHover.locked) return;
  if (projectHover.visible && projectHover.currentProjectCode === row.code) {
    if (hoverTimer) clearTimeout(hoverTimer);
    return;
  }
  if (hoverTimer) clearTimeout(hoverTimer);
  if (abortController) abortController.abort();
  hoverTimer = setTimeout(() => {
    projectHover.visible = true;
    projectHover.currentProjectCode = row.code || "";
    loadBomPreviewData(row);
  }, 450);
}

function handleProjectMouseLeave() {
  if (hoverTimer) clearTimeout(hoverTimer);
  hoverTimer = setTimeout(() => {
    if (!projectHover.locked) {
      projectHover.visible = false;
      projectHover.currentProjectCode = "";
    }
  }, 200);
}

function handleProjectHoverPanelLeave() {
  projectHover.locked = false;
  projectHover.visible = false;
  projectHover.currentProjectCode = "";
}

async function handleHoverBomRowClick(row: any) {
  if (!row.code) return;
  projectLoading.value = true;
  try {
    const res = await DataBomAPI.listRecursiveBoms(row.code, row.first_code);
    const project = allProjects.value.find(p => p.code === projectHover.currentProjectCode);
    emit("select", {
      ...project,
      id: project?.id, // 确保传递项目 ID
      first_id: row.id, // 这里的 row.id 是点击的 BOM 的 ID，即 first_id
      root_bom_code: row.code,
      parent_code: row.parent_code,
      recursive_data: res.data.data || []
    });
    isVisible.value = false;
  } finally {
    projectLoading.value = false;
  }
}

const handleProjectSearch = useDebounceFn(() => {
  projectQuery.page_no = 1;
  fetchProjects();
}, 300);

function handleSelectProject(project: any) {
  if (props.showBomTable) return;
  emit("select", project);
  isVisible.value = false;
}

function handleClose() {
  if (hoverTimer) clearTimeout(hoverTimer);
  if (abortController) abortController.abort();
  projectHover.visible = false;
}

watch(isVisible, (val) => {
  if (val) {
    const size = Math.floor((windowHeight.value - 260) / 40);
    projectQuery.page_size = size > 5 ? size : 15;
    fetchProjects(true);
  }
});

onUnmounted(() => {
  if (hoverTimer) clearTimeout(hoverTimer);
  if (abortController) abortController.abort();
});
</script>

<style lang="scss" scoped>
.project-hover-panel { 
  position: fixed; top: 130px; bottom: 80px; right: calc(40% + 15px); 
  z-index: 3000; background: var(--el-bg-color); 
  border: 1px solid var(--el-border-color-light); border-radius: 8px; 
  box-shadow: var(--el-box-shadow-dark); padding: 8px;
  display: flex; flex-direction: column;
  .loading-wrapper { width: 100%; padding: 15px; }
  :deep(.el-table) { flex: 1; }
}
.flex { display: flex; } .justify-end { justify-content: flex-end; } .mb-4 { margin-bottom: 1rem; }
</style>