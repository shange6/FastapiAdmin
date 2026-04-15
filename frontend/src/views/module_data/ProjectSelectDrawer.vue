<template>
  <el-drawer
    v-model="isVisible"
    title="选择项目"
    direction="rtl"
    size="40%"
    @close="handleClose"
  >
    <div class="project-drawer-content">
      <el-input
        v-model="projectSearch"
        placeholder="搜索项目名称、代号或合同编号"
        prefix-icon="Search"
        clearable
        class="mb-4"
        @input="handleProjectSearch"
      />
      <el-table
        v-loading="projectLoading"
        :data="projectList"
        border
        stripe
        height="calc(100vh - 200px)"
        style="width: 100%"
        :highlight-current-row="!showBomTable"
        @row-click="handleSelectProject"
        @cell-mouse-enter="handleProjectMouseEnter"
        @cell-mouse-leave="handleProjectMouseLeave"
      >
        <el-table-column
          prop="code"
          label="项目代号"
          width="150"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          prop="name"
          label="项目名称"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          prop="no"
          label="合同编号"
          width="150"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
      </el-table>
    </div>

    <!-- BOM悬浮面板 -->
    <div 
      v-show="projectHover.visible" 
      class="project-hover-panel" 
      @mouseenter="projectHover.locked = true" 
      @mouseleave="handleProjectHoverPanelLeave" 
    > 
      <el-skeleton v-if="projectHover.loading" :rows="6" animated /> 
      <el-empty v-else-if="projectHover.children.length === 0" description="无数据" /> 
      <el-table 
        v-else 
        :data="projectHover.children" 
        border 
        stripe 
        height="360" 
        style="width: 100%" 
        highlight-current-row 
        @row-click="handleHoverBomRowClick" 
      > 
        <el-table-column 
          prop="code" 
          label="代号" 
          width="140" 
          header-align="center" 
          align="center" 
          show-overflow-tooltip 
        /> 
        <el-table-column 
          prop="spec" 
          label="名称" 
          width="200" 
          header-align="center" 
          show-overflow-tooltip 
        /> 
        <el-table-column 
          prop="remark" 
          label="备注" 
          width="100" 
          header-align="center" 
          align="center" 
          show-overflow-tooltip 
        /> 
      </el-table> 
    </div> 

    <template #footer>
      <div class="flex justify-end">
        <pagination
          v-model:total="projectTotal"
          v-model:page="projectQuery.page_no"
          v-model:limit="projectQuery.page_size"
          @pagination="fetchProjects"
        />
      </div>
    </template>
  </el-drawer>
</template>

<script setup lang="ts">
import { ref, reactive, watch, onMounted, computed } from "vue";
import { useDebounceFn, useWindowSize } from "@vueuse/core";
import DataProjectAPI, { DataProjectTable } from "@/api/module_data/project";
import DataBomAPI, { DataBomTable, DataBomPageQuery } from "@/api/module_data/bom";

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  showBomTable: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update:modelValue", "select"]);

const isVisible = computed({
  get: () => props.modelValue,
  set: (val) => emit("update:modelValue", val),
});

// 可选功能：BOM预览
const projectHover = reactive({
  visible: false,
  loading: false,
  locked: false,
  children: [] as DataBomTable[],
  currentProjectCode: "",
});

const hoverTimer = ref<ReturnType<typeof setTimeout> | null>(null);

// 鼠标进入项目行
async function handleProjectMouseEnter(row: DataProjectTable) {
  if (!props.showBomTable) return;
  if (projectHover.locked) return;

  // 清除之前的定时器
  if (hoverTimer.value) clearTimeout(hoverTimer.value);

  // 设置新的定时器，悬停 500ms 后再请求数据并展示面板
  hoverTimer.value = setTimeout(async () => {
      projectHover.visible = true;
      projectHover.loading = true;
      projectHover.currentProjectCode = row.code || "";

      try {
        const res = await DataBomAPI.listProjectBoms(row.code || "");
        
        if (projectHover.currentProjectCode === row.code) {
          // 限制预览数量为前100条
          projectHover.children = (res.data.data || []).slice(0, 100);
        }
      } catch (error) {
      console.error("Fetch project BOMs error:", error);
    } finally {
      if (projectHover.currentProjectCode === row.code) {
        projectHover.loading = false;
      }
    }
  }, 500); // 延时 500ms
}

// 鼠标离开项目行
function handleProjectMouseLeave() {
  if (!props.showBomTable) return;

  // 如果鼠标在 500ms 内离开了，取消显示请求
  if (hoverTimer.value) {
    clearTimeout(hoverTimer.value);
    hoverTimer.value = null;
  }

  setTimeout(() => {
    if (!projectHover.locked) {
      projectHover.visible = false;
    }
  }, 100);
}

// 鼠标离开悬浮面板
function handleProjectHoverPanelLeave() {
  projectHover.locked = false;
  projectHover.visible = false;
}

// 点击悬浮面板中的BOM行
async function handleHoverBomRowClick(row: DataBomTable) {
  if (!row?.code) return;
  
  try {
    projectLoading.value = true;
    // 1. 获取被点击记录的 first_code 和 code
    const clickedCode = row.code;
    const clickedFirstCode = row.first_code;

    // 2. 调用后端递归查询接口，查询 first_code 相等且是 code 后代的记录
    const res = await DataBomAPI.listRecursiveBoms(clickedCode, clickedFirstCode);
    const recursiveData = res.data.data || [];

    // 3. 返回数据给父组件
    emit("select", {
      ...allProjects.value.find(p => p.code === projectHover.currentProjectCode),
      root_bom_code: clickedCode,
      parent_code: row.parent_code,
      recursive_data: recursiveData // 携带递归查询到的全量后代数据
    });
    
    isVisible.value = false;
    projectHover.visible = false;
    projectHover.locked = false;
  } catch (error) {
    console.error("Fetch recursive BOMs error:", error);
    ElMessage.error("获取后代数据失败");
  } finally {
    projectLoading.value = false;
  }
}

// 动态计算分页条数
const { height: windowHeight } = useWindowSize();
const calculatePageSize = () => {
  // 表格高度 calc(100vh - 200px)，表头约40px，每行约40px
  const tableHeight = windowHeight.value - 200;
  const size = Math.floor((tableHeight - 40) / 40);
  return size > 5 ? size : 10;
};

const projectLoading = ref(false);
const allProjects = ref<DataProjectTable[]>([]);
const projectList = ref<DataProjectTable[]>([]);
const projectTotal = ref(0);
const projectSearch = ref("");

const projectQuery = reactive({
  page_no: 1,
  page_size: calculatePageSize(),
});

// 监听窗口高度变化，动态调整分页条数
watch(windowHeight, () => {
  projectQuery.page_size = calculatePageSize();
  if (isVisible.value) {
    fetchProjects();
  }
});

// 获取项目列表
async function fetchProjects() {
  projectLoading.value = true;
  try {
    // 1. 如果缓存为空，则从后端拉取全量数据（不分页新接口）
    if (allProjects.value.length === 0) {
      const response = await DataProjectAPI.getAllDataProject();
      allProjects.value = response.data.data || [];
    }

    // 2. 本地过滤逻辑
    const keyword = projectSearch.value?.toLowerCase() || "";
    const filtered = allProjects.value.filter((item) => {
      const matchCode = !keyword || item.code?.toLowerCase().includes(keyword);
      const matchName = !keyword || item.name?.toLowerCase().includes(keyword);
      const matchNo = !keyword || item.no?.toLowerCase().includes(keyword);
      return matchCode || matchName || matchNo;
    });

    // 3. 处理本地分页
    projectTotal.value = filtered.length;
    const start = (projectQuery.page_no - 1) * projectQuery.page_size;
    const end = start + projectQuery.page_size;
    projectList.value = filtered.slice(start, end);
  } catch (error) {
    console.error("Fetch projects error:", error);
  } finally {
    projectLoading.value = false;
  }
}

// 搜索项目（防抖）
const handleProjectSearch = useDebounceFn(() => {
  projectQuery.page_no = 1;
  fetchProjects();
}, 300);

// 选择项目
function handleSelectProject(project: DataProjectTable) {
  if (props.showBomTable) return; // 如果启用了BOM预览，禁用直接点击项目选择
  emit("select", project);
  isVisible.value = false;
}

function handleClose() {
  isVisible.value = false;
}

onMounted(async () => {
  fetchProjects(); // 预加载项目列表
});
</script>

<style lang="scss" scoped>
:deep(.el-drawer__body) {
  padding-bottom: 0;
}
:deep(.el-drawer__footer) {
  border-top: none;
  padding-top: 0;
  padding-bottom: 20px;
}

.project-hover-panel { 
  position: fixed; 
  top: 110px; 
  right: calc(40% + 16px); 
  width: 460px; 
  max-width: calc(60% - 32px); 
  padding: 10px; 
  border: 1px solid var(--el-border-color); 
  border-radius: 10px; 
  background: var(--el-bg-color); 
  box-shadow: var(--el-box-shadow-light); 
  z-index: 9999; 
  pointer-events: auto; 
} 

.project-hover-panel :deep(.el-table__inner-wrapper) { 
  border-radius: 8px; 
} 
</style>
