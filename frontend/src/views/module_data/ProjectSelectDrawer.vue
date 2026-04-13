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
        highlight-current-row
        @row-click="handleSelectProject"
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

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update:modelValue", "select"]);

const isVisible = computed({
  get: () => props.modelValue,
  set: (val) => emit("update:modelValue", val),
});

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
</style>
