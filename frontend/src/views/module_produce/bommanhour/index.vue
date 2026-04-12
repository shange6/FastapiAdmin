<!-- BOM路线关联 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <div class="card-header">
          <span>
            BOM工时关联列表
            <el-tooltip content="BOM工时关联列表">
              <QuestionFilled class="w-4 h-4 mx-1" />
            </el-tooltip>
          </span>
        </div>

        <!-- 搜索区域 -->
        <div v-show="visible" class="search-container">
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
                全部展开
              </el-button>
              <el-button type="info" plain icon="Fold" @click="toggleAllExpansion(false)">
                全部收起
              </el-button>
              <!-- <el-button
                v-hasPerm="['module_produce:bomroute:create']"
                type="warning"
                icon="FolderChecked"
                @click="handleBatchSaveCraftRoute"
              >
                批量保存
              </el-button> -->
              <el-button type="primary" icon="Collection" @click="handleOpenProjectDrawer">
                选择项目
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </template>

      <!-- 功能区域 -->
      <!-- <div class="data-table__toolbar">
        <div class="data-table__toolbar--left">
          <el-row :gutter="10">
            <el-col :span="1.5">
              <el-button
                v-hasPerm="['module_produce:bomroute:create']"
                type="success"
                icon="plus"
                @click="handleOpenDialog('create')"
              >
                新增
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-button
                v-hasPerm="['module_produce:bomroute:delete']"
                type="danger"
                icon="delete"
                :disabled="selectIds.length === 0"
                @click="handleDelete(selectIds)"
              >
                批量删除
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-dropdown v-hasPerm="['module_produce:bomroute:batch']" trigger="click">
                <el-button type="default" :disabled="selectIds.length === 0" icon="ArrowDown">
                  更多
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item :icon="Check" @click="handleMoreClick('0')">
                      批量启用
                    </el-dropdown-item>
                    <el-dropdown-item :icon="CircleClose" @click="handleMoreClick('1')">
                      批量停用
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </el-col>
          </el-row>
        </div>
        <div class="data-table__toolbar--right">
          <el-row :gutter="10">
            <el-col :span="1.5">
              <el-tooltip content="导入">
                <el-button
                  v-hasPerm="['module_produce:bomroute:import']"
                  type="success"
                  icon="upload"
                  circle
                  @click="handleOpenImportDialog"
                />
              </el-tooltip>
            </el-col>
            <el-col :span="1.5">
              <el-tooltip content="导出">
                <el-button
                  v-hasPerm="['module_produce:bomroute:export']"
                  type="warning"
                  icon="download"
                  circle
                  @click="handleOpenExportsModal"
                />
              </el-tooltip>
            </el-col>
            <el-col :span="1.5">
              <el-tooltip content="搜索显示/隐藏">
                <el-button
                  v-hasPerm="['*:*:*']"
                  type="info"
                  icon="search"
                  circle
                  @click="visible = !visible"
                />
              </el-tooltip>
            </el-col>
            <el-col :span="1.5">
              <el-tooltip content="刷新">
                <el-button
                  v-hasPerm="['module_produce:bomroute:query']"
                  type="primary"
                  icon="refresh"
                  circle
                  @click="handleRefresh"
                />
              </el-tooltip>
            </el-col>
            <el-col :span="1.5">
              <el-popover placement="bottom" trigger="click">
                <template #reference>
                  <el-button type="danger" icon="operation" circle></el-button>
                </template>
                <el-scrollbar max-height="350px">
                  <template v-for="column in tableColumns" :key="column.prop">
                    <el-checkbox v-if="column.prop" v-model="column.show" :label="column.label" />
                  </template>
                </el-scrollbar>
              </el-popover>
            </el-col>
          </el-row>
        </div>
      </div> -->

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
          v-if="tableColumns.find((col) => col.prop === 'selection')?.show"
          type="selection"
          min-width="40"
          align="center"
        />
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'index')?.show"
          fixed
          label="序号"
          min-width="60"
        >
          <template #default="scope">
            {{ (queryFormData.page_no - 1) * queryFormData.page_size + scope.$index + 1 }}
          </template>
        </el-table-column>         -->
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'code')?.show"
          label="代号"
          prop="code"
          min-width="280"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'spec')?.show"
          label="名称"
          prop="spec"
          min-width="180"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'count')?.show"
          label="数量"
          prop="count"
          min-width="60"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'material')?.show"
          label="材质"
          prop="material"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'unit_mass')?.show"
          label="单重"
          prop="unit_mass"
          min-width="70"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'total_mass')?.show"
          label="总重"
          prop="total_mass"
          min-width="70"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'remark')?.show"
          label="备注"
          prop="remark"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'craft_route')?.show"
          label="路线"
          prop="route_code"
          min-width="60"
          align="center"
          header-align="center"
          fixed="right"
        >
          <template #default="scope">
            <!-- 直接显示：route_code + route_name，和原来下拉框展示一样 -->
            <span>{{ scope.row.route_code }}</span>
          </template>
        </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'manhour')?.show"
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
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'operation')?.show"
          fixed="right"
          label="操作"
          align="center"
          min-width="60"
        >
          <template #default="scope">
            <el-button
              v-hasPerm="['module_produce:bommanhour:update']"
              type="primary"
              link
              @click="handleOpenManhourDialog(scope.row)"
            >
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页区域 -->
      <!-- <template #footer>
        <pagination
          v-model:total="total"
          v-model:page="queryFormData.page_no"
          v-model:limit="queryFormData.page_size"
          @pagination="loadingData"
        />
      </template> -->
    </el-card>

    <!-- 项目选择抽屉 -->
    <el-drawer v-model="projectDrawerVisible" title="选择项目" direction="rtl" size="40%">
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
          height="calc(100vh - 220px)"
          style="width: 100%"
          highlight-current-row
          @cell-mouse-enter="handleProjectRowMouseEnter"
          @cell-mouse-leave="handleProjectRowMouseLeave"
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
        <div class="mt-4 flex justify-end">
          <pagination
            v-model:total="projectTotal"
            v-model:page="projectQuery.page_no"
            v-model:limit="projectQuery.page_size"
            @pagination="fetchProjects"
          />
        </div>

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
      </div>
    </el-drawer>

    <!-- 弹窗区域 -->
    <el-dialog
      v-model="dialogVisible.visible"
      :title="dialogVisible.title"
      @close="handleCloseDialog"
    >
      <!-- 详情 -->
      <template v-if="dialogVisible.type === 'detail'">
        <el-descriptions :column="4" border>
          <el-descriptions-item label="BOMID" :span="2">
            {{ detailFormData.bom_id }}
          </el-descriptions-item>
          <el-descriptions-item label="工艺路线" :span="2">
            {{ detailFormData.route }}
          </el-descriptions-item>
        </el-descriptions>
      </template>

      <!-- 新增、编辑表单 -->
      <template v-else>
        <el-form
          ref="dataFormRef"
          :model="formData"
          :rules="rules"
          label-suffix=":"
          label-width="auto"
          label-position="right"
        >
          <el-form-item label="BOMID" prop="bom_id" :required="false">
            <el-input v-model="formData.bom_id" placeholder="请输入BOMID" />
          </el-form-item>
          <el-form-item label="工艺路线" prop="route" :required="false">
            <el-input v-model="formData.route" placeholder="请输入工艺路线" />
          </el-form-item>
        </el-form>
      </template>

      <template #footer>
        <div class="dialog-footer">
          <!-- 详情弹窗不需要确定按钮的提交逻辑 -->
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button v-if="dialogVisible.type !== 'detail'" type="primary" @click="handleSubmit">
            确定
          </el-button>
          <el-button v-else type="primary" @click="handleCloseDialog">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog
      v-model="manhourDialogVisible"
      title="工时"
      width="600px"
      top="5vh"
      @close="handleCloseManhourDialog"
    >
      <el-descriptions v-if="manhourBom" :column="2" border>
        <el-descriptions-item label-align="center" label="代号">
          {{ manhourBom.code }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="数量">
          {{ manhourBom.count }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="名称">
          {{ manhourBom.spec }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="单重">
          {{ manhourBom.unit_mass }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="材质">
          {{ manhourBom.material }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="总重">
          {{ manhourBom.total_mass }}
        </el-descriptions-item>
        <el-descriptions-item label-align="center" label="备注" :span="2">
          {{ manhourBom.remark }}
        </el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">工艺工时</el-divider>
      <el-skeleton v-if="manhourLoading" :rows="6" animated />
      <el-empty v-else-if="manhourSteps.length === 0" description="该路线未配置工艺" />
      <el-form v-else label-position="left" style="padding-left: 0px; margin-bottom: -0px">
        <div
          v-for="group in manhourStepGroups"
          :key="group[0].key"
          style="display: flex; gap: 12px"
        >
          <el-form-item :label="group[0].label" style="flex: 1">
            <el-input-number
              v-model="group[0].manhour"
              :min="0"
              :step="1"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <el-form-item v-if="group[1]" :label="group[1].label" style="flex: 1">
            <el-input-number
              v-model="group[1].manhour"
              :min="0"
              :step="1"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <div v-else style="flex: 1"></div>
          <el-form-item v-if="group[2]" :label="group[2].label" style="flex: 1">
            <el-input-number
              v-model="group[2].manhour"
              :min="0"
              :step="1"
              controls-position="right"
              style="width: 120px"
            />
          </el-form-item>
          <div v-else style="flex: 1"></div>
        </div>
      </el-form>

      <template #footer>
        <el-button @click="handleCloseManhourDialog">取消</el-button>
        <el-button type="primary" @click="handleConfirmManhourDialog">保存工时</el-button>
      </template>
    </el-dialog>

    <!-- 导入弹窗 -->
    <ImportModal
      v-model="importDialogVisible"
      :content-config="curdContentConfig"
      :loading="uploadLoading"
      @upload="handleUpload"
    />

    <!-- 导出弹窗 -->
    <ExportModal
      v-model="exportsDialogVisible"
      :content-config="curdContentConfig"
      :query-params="queryFormData"
      :page-data="pageTableData"
      :selection-data="selectionRows"
    />
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "ProduceBomRoute",
  inheritAttrs: false,
});

import { ref, reactive, onMounted, computed } from "vue";
import { useDebounceFn } from "@vueuse/core";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  QuestionFilled,
  ArrowUp,
  ArrowDown,
  Check,
  CircleClose,
  FolderChecked,
  Expand,
  Fold,
  Collection,
} from "@element-plus/icons-vue";
import { formatToDateTime } from "@/utils/dateUtil";
import { useDictStore } from "@/store";
import { ResultEnum } from "@/enums/api/result.enum";
import DatePicker from "@/components/DatePicker/index.vue";
import type { IContentConfig } from "@/components/CURD/types";
import ImportModal from "@/components/CURD/ImportModal.vue";
import ExportModal from "@/components/CURD/ExportModal.vue";
import ProduceBomRouteAPI, {
  ProduceBomRoutePageQuery,
  ProduceBomRouteTable,
  ProduceBomRouteForm,
} from "@/api/module_produce/bomroute";
import DataBomAPI, { DataBomTable } from "@/api/module_data/bom";
import DataProjectAPI, { DataProjectTable } from "@/api/module_data/project";
import ProduceCraftRouteAPI, { CraftRouteView } from "@/api/module_produce/craftroute";
import ProduceBomManhourAPI from "@/api/module_produce/bommanhour";
import { convertToTree } from "@/views/module_data/utils";

const visible = ref(true);
const tableRef = ref();
const queryFormRef = ref();
const dataFormRef = ref();
const total = ref(0);
const selectIds = ref<number[]>([]);
const selectionRows = ref<ProduceBomRouteTable[]>([]);
const loading = ref(false);
const isExpand = ref(false);
const isExpandable = ref(true);

const manhourDialogVisible = ref(false);
const manhourLoading = ref(false);
const manhourBom = ref<any | null>(null);
const manhourSteps = ref<
  { key: string; label: string; craft_id: number; manhour: number | null }[]
>([]);

const manhourStepGroups = computed(() => {
  const groups: [
    { key: string; label: string; craft_id: number; manhour: number | null },
    { key: string; label: string; craft_id: number; manhour: number | null } | null,
    { key: string; label: string; craft_id: number; manhour: number | null } | null,
  ][] = [];
  for (let i = 0; i < manhourSteps.value.length; i += 3) {
    groups.push([
      manhourSteps.value[i],
      manhourSteps.value[i + 1] ?? null,
      manhourSteps.value[i + 2] ?? null,
    ]);
  }
  return groups;
});

// 分页表单
const pageTableData = ref<DataBomTable[]>([]);

// 工艺路线下拉选项
const craftRouteOptions = ref<any[]>([]);

// 项目选择相关
const projectDrawerVisible = ref(false);
const projectLoading = ref(false);
const projectList = ref<DataProjectTable[]>([]);
const projectTotal = ref(0);
const projectSearch = ref("");
const projectQuery = reactive({
  page_no: 1,
  page_size: 20,
});

const projectHover = reactive({
  visible: false,
  locked: false,
  project: null as DataProjectTable | null,
  children: [] as DataBomTable[],
  loading: false,
});

const projectChildrenCache = reactive<Record<string, DataBomTable[]>>({});

// 表格列配置
const tableColumns = ref([
  { prop: "selection", label: "选择框", show: true },
  { prop: "index", label: "序号", show: true },
  { prop: "code", label: "代号", show: true },
  { prop: "spec", label: "名称", show: true },
  { prop: "craft_route", label: "工艺路线", show: true },
  { prop: "count", label: "数量", show: true },
  { prop: "material", label: "材质", show: true },
  { prop: "unit_mass", label: "单重", show: true },
  { prop: "total_mass", label: "总重", show: true },
  { prop: "remark", label: "备注", show: true },
  { prop: "manhour", label: "工时", show: true },
  { prop: "operation", label: "操作", show: true },
]);

// 导出列（不含选择/序号/操作）
const exportColumns: Record<string, string>[] = [];

// 导入/导出配置
const curdContentConfig = {
  permPrefix: "module_produce:bomroute",
  cols: exportColumns as any,
  importTemplate: () => ProduceBomRouteAPI.downloadTemplateProduceBomRoute(),
  exportsAction: async (params: any) => {
    const query: any = { ...params };
    query.status = "0";
    query.page_no = 1;
    query.page_size = 9999;
    const all: any[] = [];
    while (true) {
      const res = await ProduceBomRouteAPI.listProduceBomRoute(query);
      const items = res.data?.data?.items || [];
      const total = res.data?.data?.total || 0;
      all.push(...items);
      if (all.length >= total || items.length === 0) break;
      query.page_no += 1;
    }
    return all;
  },
} as unknown as IContentConfig;

// 详情表单
const detailFormData = ref<ProduceBomRouteTable>({});
// 日期范围临时变量
const createdDateRange = ref<[Date, Date] | []>([]);
// 更新时间范围临时变量
const updatedDateRange = ref<[Date, Date] | []>([]);

// 处理创建时间范围变化
function handleCreatedDateRangeChange(range: [Date, Date]) {
  createdDateRange.value = range;
  if (range && range.length === 2) {
    queryFormData.created_time = [formatToDateTime(range[0]), formatToDateTime(range[1])];
  } else {
    queryFormData.created_time = undefined;
  }
}

// 处理更新时间范围变化
function handleUpdatedDateRangeChange(range: [Date, Date]) {
  updatedDateRange.value = range;
  if (range && range.length === 2) {
    queryFormData.updated_time = [formatToDateTime(range[0]), formatToDateTime(range[1])];
  } else {
    queryFormData.updated_time = undefined;
  }
}

// 分页查询参数
type QueryFormData = ProduceBomRoutePageQuery & { parent_code?: string };
const queryFormData = reactive<QueryFormData>({
  page_no: 1,
  page_size: 10,
});

// 编辑表单
const formData = reactive<ProduceBomRouteForm>({
  bom_id: undefined,
  route: undefined,
});

// 字典仓库与需要加载的字典类型
const dictStore = useDictStore();
const dictTypes: any = [];

// 弹窗状态
const dialogVisible = reactive({
  title: "",
  visible: false,
  type: "create" as "create" | "update" | "detail",
});

// 表单验证规则
const rules = reactive({
  bom_id: [{ required: false, message: "请输入BOMID", trigger: "blur" }],
  route: [{ required: false, message: "请输入工艺路线", trigger: "blur" }],
});

// 导入弹窗显示状态
const importDialogVisible = ref(false);
const uploadLoading = ref(false);

// 导出弹窗显示状态
const exportsDialogVisible = ref(false);

// 打开导入弹窗
function handleOpenImportDialog() {
  importDialogVisible.value = true;
}

// 打开导出弹窗
function handleOpenExportsModal() {
  exportsDialogVisible.value = true;
}

// 列表刷新
async function handleRefresh() {
  await loadingData();
}

// 加载表格数据
// 全量缓存
const allBoms = ref<DataBomTable[]>([]);
const allBomRoutes = ref<any[]>([]);
const selectedRootBomCode = ref<string | undefined>(undefined);
const routeCraftIdsCache = new Map<number, number[]>();

function getRouteName(routeCode: any) {
  const matched = (craftRouteOptions.value || []).find((opt: any) => opt.route_code === routeCode);
  return matched?.route_name;
}

function syncCraftRouteToTree(nodes: any[]) {
  if (!nodes) return;
  nodes.forEach((node: any) => {
    const routeRecord = allBomRoutes.value.find((r: any) => r.bom_id === node.id);
    if (routeRecord) {
      node.route_code = routeRecord.route;
      node.route_name = getRouteName(routeRecord.route);
      node.craft_route = routeRecord.route;
    } else {
      node.route_code = undefined;
      node.route_name = undefined;
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

async function ensureRouteCraftIdsLoaded(routeCodes: number[]) {
  const unique = Array.from(new Set(routeCodes.filter((r) => Number.isFinite(r) && r > 0)));
  const missing = unique.filter((r) => !routeCraftIdsCache.has(r));
  if (missing.length === 0) return;

  const results = await Promise.all(
    missing.map(async (routeCode) => {
      try {
        const res = await ProduceCraftRouteAPI.detailProduceCraftRoute(routeCode);
        const items = res.data?.data?.items || [];
        const craftIds = items
          .map((i: any) => Number(i?.craft_id))
          .filter((id: number) => Number.isFinite(id) && id > 0);
        return { routeCode, craftIds };
      } catch {
        return { routeCode, craftIds: [] as number[] };
      }
    })
  );

  results.forEach(({ routeCode, craftIds }) => {
    routeCraftIdsCache.set(routeCode, craftIds);
  });
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
  if (!selectedRootBomCode.value) {
    pageTableData.value = [];
    total.value = 0;
    return;
  }

  ElMessage.info("正在更新数据... ...请稍后");
  loading.value = true;
  try {
    await Promise.all([ensureAllBomsLoadedForProjectHover(), ensureAllBomRoutesLoaded()]);

    allBoms.value.forEach((bom: any) => {
      const routeRecord = allBomRoutes.value.find((r: any) => r.bom_id === bom.id);
      if (routeRecord) {
        bom.route_code = routeRecord.route;
        bom.route_name = getRouteName(routeRecord.route);
        bom.craft_route = routeRecord.route;
      } else {
        bom.route_code = undefined;
        bom.route_name = undefined;
      }
    });

    const subtree = collectSubtreeByRootCode(allBoms.value as any[], selectedRootBomCode.value);
    const bomIds = Array.from(
      new Set(
        subtree.map((b: any) => Number(b?.id)).filter((id: number) => Number.isFinite(id) && id > 0)
      )
    );
    await ensureRouteCraftIdsLoaded(
      subtree
        .map((b: any) => Number(b?.route_code))
        .filter((v: number) => Number.isFinite(v) && v > 0)
    );
    if (bomIds.length > 0) {
      const manhourRes = await ProduceBomManhourAPI.summaryBatchProduceBomManhour({
        bom_ids: bomIds,
        recursive: false,
      });
      const manhourMap = manhourRes.data?.data || {};
      subtree.forEach((bom: any) => {
        bom.manhour = manhourMap[String(bom.id)] || [];
      });
    }
    const { tree } = convertToTree(subtree, undefined, selectedRootBomCode.value);
    syncCraftRouteToTree(tree);
    pageTableData.value = tree;
    total.value = tree.length;
  } catch (error: any) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

function isManhourComplete(row: any) {
  const routeCode = Number(row.route_code);
  if (!routeCode || !routeCraftIdsCache.has(routeCode)) return false;

  const expectedCraftIds = routeCraftIdsCache.get(routeCode) || [];
  if (expectedCraftIds.length === 0) return false;

  const actualManhours = (Array.isArray(row.manhour) ? row.manhour : []) as any[];
  // 过滤掉工时为 0 或空的记录，并按工艺名称去重（防止异常数据影响）
  const validCraftNames = new Set(
    actualManhours.filter((m: any) => Number(m.manhour) > 0).map((m: any) => m.craft_name)
  );

  return validCraftNames.size === expectedCraftIds.length;
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

// 选择创建人后触发查询
function handleConfirm() {
  handleQuery();
}

// 重置查询
async function handleResetQuery() {
  queryFormRef.value.resetFields();
  queryFormData.page_no = 1;
  createdDateRange.value = [];
  updatedDateRange.value = [];
  queryFormData.created_time = undefined;
  queryFormData.updated_time = undefined;
  allBoms.value = [];
  loadingData();
}

// 项目搜索防抖
const debouncedProjectSearch = useDebounceFn(() => {
  projectQuery.page_no = 1;
  fetchProjects();
}, 300);

// 项目搜索处理
function handleProjectSearch() {
  debouncedProjectSearch();
}

// 获取项目列表
async function fetchProjects() {
  projectLoading.value = true;
  try {
    const params: any = {
      page_no: projectQuery.page_no,
      page_size: projectQuery.page_size,
    };
    if (projectSearch.value) {
      params.keyword = projectSearch.value;
    }
    const res = await DataProjectAPI.listDataProject(params);
    projectList.value = res.data.data.items || [];
    projectTotal.value = res.data.data.total || 0;
  } catch (error) {
    console.error("Fetch projects error:", error);
  } finally {
    projectLoading.value = false;
  }
}

async function ensureAllBomsLoadedForProjectHover() {
  if (allBoms.value.length > 0) return;
  const res = await DataBomAPI.listDataBomNoProcure();
  allBoms.value = res.data.data || [];
}

async function loadProjectFirstLevelChildren(projectCode: string) {
  if (!projectCode) {
    projectHover.children = [];
    return;
  }

  const cached = projectChildrenCache[projectCode];
  if (cached) {
    projectHover.children = cached;
    return;
  }

  projectHover.loading = true;
  try {
    await ensureAllBomsLoadedForProjectHover();
    const children = (allBoms.value as any[]).filter((bom: any) => bom.parent_code === projectCode);
    projectChildrenCache[projectCode] = children;
    projectHover.children = children;
  } finally {
    projectHover.loading = false;
  }
}

let projectHoverHideTimer: any = null;

function handleProjectRowMouseEnter(row: DataProjectTable) {
  if (projectHoverHideTimer) {
    clearTimeout(projectHoverHideTimer);
    projectHoverHideTimer = null;
  }
  projectHover.project = row;
  projectHover.visible = true;
  projectHover.locked = false;
  loadProjectFirstLevelChildren(row.code as any);
}

function handleProjectRowMouseLeave() {
  if (projectHoverHideTimer) clearTimeout(projectHoverHideTimer);
  projectHoverHideTimer = setTimeout(() => {
    if (!projectHover.locked) projectHover.visible = false;
  }, 120);
}

function handleProjectHoverPanelLeave() {
  projectHover.locked = false;
  projectHover.visible = false;
}

function handleHoverBomRowClick(row: DataBomTable) {
  if (!row?.code) return;
  selectedRootBomCode.value = row.code as any;
  queryFormData.parent_code = row.parent_code as any;
  projectDrawerVisible.value = false;
  projectHover.visible = false;
  projectHover.locked = false;
  loadingData();
}

async function handleOpenManhourDialog(row: any) {
  manhourBom.value = row;
  manhourDialogVisible.value = true;
  manhourSteps.value = [];
  const routeCode = row?.route_code ?? row?.craft_route;
  if (!routeCode) return;

  manhourLoading.value = true;
  try {
    const [routeRes, manhourRes] = await Promise.all([
      ProduceCraftRouteAPI.detailProduceCraftRoute(Number(routeCode)),
      ProduceBomManhourAPI.listProduceBomManhour({
        bom_id: String(Number(row?.id)),
      } as any),
    ]);

    const items = routeRes.data?.data?.items || [];
    const manhourData: any = manhourRes.data?.data;
    const existedManhours = Array.isArray(manhourData) ? manhourData : manhourData?.items || [];
    const manhourMap = new Map<number, number>();
    existedManhours.forEach((m: any) => {
      const craftId = Number(m?.craft_id);
      const manhour = Number(m?.manhour);
      if (!Number.isFinite(craftId) || craftId <= 0) return;
      if (!Number.isFinite(manhour) || manhour <= 0) return;
      manhourMap.set(craftId, manhour);
    });

    manhourSteps.value = items.map((item: any) => {
      const craftId = Number(item?.craft_id);
      return {
        key: `${item.route ?? routeCode}-${craftId}`,
        label: `${item.craft_name ?? item.craft_names ?? craftId}`.trim(),
        craft_id: craftId,
        manhour: manhourMap.get(craftId) ?? null,
      };
    });
  } catch (error: any) {
    console.error(error);
    manhourSteps.value = [];
  } finally {
    manhourLoading.value = false;
  }
}

function handleCloseManhourDialog() {
  manhourDialogVisible.value = false;
  manhourLoading.value = false;
  manhourBom.value = null;
  manhourSteps.value = [];
}

async function handleConfirmManhourDialog() {
  const bomId = Number(manhourBom.value?.id);
  if (!bomId) {
    ElMessage.error("未找到BOM ID，无法保存");
    return;
  }

  const items = (manhourSteps.value || [])
    .map((s) => ({
      bom_id: bomId,
      craft_id: Number(s.craft_id),
      manhour: Number(s.manhour ?? 0),
    }))
    .filter((s) => s.craft_id);

  // 构造前端显示的工时数组
  const manhourArray = (manhourSteps.value || [])
    .filter((s) => Number(s.manhour ?? 0) > 0)
    .map((s) => ({
      craft_id: Number(s.craft_id),
      craft_name: s.label,
      manhour: Number(s.manhour),
    }));

  try {
    manhourLoading.value = true;
    await ProduceBomManhourAPI.upsertBatchProduceBomManhour({ items });
    const bom = (allBoms.value as any[]).find((item: any) => item.id === bomId);
    if (bom) bom.manhour = manhourArray;
    if (manhourBom.value) manhourBom.value.manhour = manhourArray;
    updateTreeManhourById(pageTableData.value as any[], bomId, manhourArray);
    manhourDialogVisible.value = false;
  } catch (error: any) {
    console.error(error);
  } finally {
    manhourLoading.value = false;
  }
}

// 打开项目选择抽屉
async function handleOpenProjectDrawer() {
  projectDrawerVisible.value = true;
  fetchProjects();
}

// 选择项目
function handleSelectProject(project: DataProjectTable) {
  queryFormData.parent_code = project.code;
  projectDrawerVisible.value = false;
  allBoms.value = [];
  handleQuery();
}

// 定义初始表单数据常量
const initialFormData: ProduceBomRouteForm = {
  bom_id: undefined,
  route: undefined,
};

// 重置表单
async function resetForm() {
  if (dataFormRef.value) {
    dataFormRef.value.resetFields();
    dataFormRef.value.clearValidate();
  }
  // 完全重置 formData 为初始状态
  Object.assign(formData, initialFormData);
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

function updateTreeManhourById(nodes: any[], bomId: number, manhour: any[]): boolean {
  for (const node of nodes || []) {
    if (node.id === bomId) {
      node.manhour = manhour;
      return true;
    }
    if (node.children && node.children.length > 0) {
      const updated = updateTreeManhourById(node.children, bomId, manhour);
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
    if (selectionRows.value.length === 0) {
      ElMessage.warning("请先选择记录");
      return;
    }
    const changedRows = (selectionRows.value as any[]).filter(
      (item: any) => item.craft_route !== undefined && item.craft_route !== null
    );
    if (changedRows.length === 0) {
      ElMessage.warning("请先选择工艺路线");
      return;
    }
    loading.value = true;
    const data = changedRows.map((row: any) => ({
      bom_id: row.id,
      route: row.craft_route,
    }));
    await ProduceBomRouteAPI.upsertBatchProduceBomRoute(data);
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

// 关闭弹窗
async function handleCloseDialog() {
  dialogVisible.visible = false;
  resetForm();
}

// 打开弹窗
async function handleOpenDialog(type: "create" | "update" | "detail", id?: number) {
  dialogVisible.type = type;
  if (id) {
    const response = await ProduceBomRouteAPI.detailProduceBomRoute(id);
    if (type === "detail") {
      dialogVisible.title = "详情";
      Object.assign(detailFormData.value, response.data.data);
    } else if (type === "update") {
      dialogVisible.title = "修改";
      Object.assign(formData, response.data.data);
    }
  } else {
    dialogVisible.title = "新增ProduceBomRoute";
    formData.bom_id = undefined;
    formData.route = undefined;
  }
  dialogVisible.visible = true;
}

// 提交表单（防抖）
async function handleSubmit() {
  // 表单校验
  dataFormRef.value.validate(async (valid: any) => {
    if (valid) {
      loading.value = true;
      // 根据弹窗传入的参数(deatil\create\update)判断走什么逻辑
      const submitData = { ...formData };
      const id = formData.id;
      if (id) {
        try {
          await ProduceBomRouteAPI.updateProduceBomRoute(id, { id, ...submitData });
          dialogVisible.visible = false;
          resetForm();
          handleCloseDialog();
          handleResetQuery();
        } catch (error: any) {
          console.error(error);
        } finally {
          loading.value = false;
        }
      } else {
        try {
          await ProduceBomRouteAPI.createProduceBomRoute(submitData);
          dialogVisible.visible = false;
          resetForm();
          handleCloseDialog();
          handleResetQuery();
        } catch (error: any) {
          console.error(error);
        } finally {
          loading.value = false;
        }
      }
    }
  });
}

// 删除、批量删除
async function handleDelete(ids: number[]) {
  ElMessageBox.confirm("确认删除该项数据?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        loading.value = true;
        await ProduceBomRouteAPI.deleteProduceBomRoute(ids);
        handleResetQuery();
      } catch (error: any) {
        console.error(error);
      } finally {
        loading.value = false;
      }
    })
    .catch(() => {
      ElMessageBox.close();
    });
}

// 批量启用/停用
async function handleMoreClick(status: string) {
  if (selectIds.value.length) {
    ElMessageBox.confirm(`确认${status === "0" ? "启用" : "停用"}该项数据?`, "警告", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    })
      .then(async () => {
        try {
          loading.value = true;
          await ProduceBomRouteAPI.batchProduceBomRoute({ ids: selectIds.value, status });
          handleResetQuery();
        } catch (error: any) {
          console.error(error);
        } finally {
          loading.value = false;
        }
      })
      .catch(() => {
        ElMessageBox.close();
      });
  }
}

// 处理上传
const handleUpload = async (formData: FormData) => {
  try {
    uploadLoading.value = true;
    const response = await ProduceBomRouteAPI.importProduceBomRoute(formData);
    if (response.data.code === ResultEnum.SUCCESS) {
      ElMessage.success(`${response.data.msg}，${response.data.data}`);
      importDialogVisible.value = false;
      await handleQuery();
    }
  } catch (error: any) {
    console.error(error);
  } finally {
    uploadLoading.value = false;
  }
};

onMounted(async () => {
  // 预加载字典数据
  if (dictTypes.length > 0) {
    await dictStore.getDict(dictTypes);
  }
  await loadCraftRouteOptions();
  pageTableData.value = [];
});
</script>

<style lang="scss" scoped>
.project-drawer-content {
  position: relative;
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
