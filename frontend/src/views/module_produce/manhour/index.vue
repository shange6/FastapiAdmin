<!-- 工时管理 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <!-- <div class="card-header">
          <span>
            工时管理列表
            <el-tooltip content="工时管理列表">
              <QuestionFilled class="w-4 h-4 mx-1" />
            </el-tooltip>
          </span>
        </div> -->

        <!-- 搜索区域 -->
        <div v-show="visible" class="search-container">
          <el-form
            ref="queryFormRef"
            :model="queryFormData"
            label-suffix=":"
            :inline="true"
            @submit.prevent="handleQuery"
          >
            <el-form-item label="零件名称" prop="name">
              <el-input v-model="queryFormData.name" placeholder="请输入零件名称" clearable />
            </el-form-item>
            <!-- <el-form-item label="零件型号" prop="model">
              <el-input v-model="queryFormData.model" placeholder="请输入零件型号" clearable />
            </el-form-item>
            <el-form-item label="材质" prop="material">
              <el-input v-model="queryFormData.material" placeholder="请输入材质" clearable />
            </el-form-item> -->
            <el-form-item label="计算单位" prop="unit">
              <el-select v-model="queryFormData.unit" placeholder="请选择单位" clearable style="width: 150px">
                <el-option label="重量" value="g" />
                <el-option label="长度" value="m" />
                <el-option label="件" value="p" />
              </el-select>
            </el-form-item>
            <!-- <el-form-item label="单位工时ms" prop="unit_hour">
              <el-input-number v-model="queryFormData.unit_hour" placeholder="单位工时ms" clearable style="width: 200px" :controls="false" />
            </el-form-item>
            <el-form-item label="下料比率" prop="blanking_ratio">
              <el-input-number v-model="queryFormData.blanking_ratio" placeholder="下料比率" clearable style="width: 200px" :controls="false" />
            </el-form-item>
            <el-form-item label="铆焊比率" prop="welding_ratio">
              <el-input-number v-model="queryFormData.welding_ratio" placeholder="铆焊比率" clearable style="width: 200px" :controls="false" />
            </el-form-item>
            <el-form-item label="装配比率" prop="fitting_ratio">
              <el-input-number v-model="queryFormData.fitting_ratio" placeholder="装配比率" clearable style="width: 200px" :controls="false" />
            </el-form-item>
            <el-form-item v-if="isExpand" prop="created_time" label="创建时间">
              <DatePicker
                v-model="createdDateRange"
                @update:model-value="handleCreatedDateRangeChange"
              />
            </el-form-item>
            <el-form-item v-if="isExpand" prop="updated_time" label="更新时间">
              <DatePicker
                v-model="updatedDateRange"
                @update:model-value="handleUpdatedDateRangeChange"
              />
            </el-form-item>
            <el-form-item v-if="isExpand" prop="created_id" label="创建人">
              <UserTableSelect
                v-model="queryFormData.created_id"
                @confirm-click="handleConfirm"
                @clear-click="handleQuery"
              />
            </el-form-item>
            <el-form-item v-if="isExpand" prop="updated_id" label="更新人">
              <UserTableSelect
                v-model="queryFormData.updated_id"
                @confirm-click="handleConfirm"
                @clear-click="handleQuery"
              />
            </el-form-item> -->
            <!-- 查询、重置、展开/收起按钮 -->
            <el-form-item>
              <el-button
                v-hasPerm="['module_produce:manhour:query']"
                type="primary"
                icon="search"
                @click="handleQuery"
              >
                查询
              </el-button>
              <el-button
                v-hasPerm="['module_produce:manhour:query']"
                icon="refresh"
                @click="handleResetQuery"
              >
                重置
              </el-button>
              <!-- 展开/收起 -->
              <!-- <template v-if="isExpandable">
                <el-link 
                  class="ml-3"
                  type="primary"
                  underline="never"
                  @click="isExpand = !isExpand"
                >
                  {{ isExpand ? "收起" : "展开" }}
                  <el-icon>
                    <template v-if="isExpand">
                      <ArrowUp />
                    </template>
                    <template v-else>
                      <ArrowDown />
                    </template>
                  </el-icon>
                </el-link>
              </template> -->
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
                v-hasPerm="['module_produce:manhour:create']"
                type="success"
                icon="plus"
                @click="handleOpenDialog('create')"
              >
                新增
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-button
                v-hasPerm="['module_produce:manhour:delete']"
                type="danger"
                icon="delete"
                :disabled="selectIds.length === 0"
                @click="handleDelete(selectIds)"
              >
                批量删除
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-dropdown v-hasPerm="['module_produce:manhour:batch']" trigger="click">
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
                  v-hasPerm="['module_produce:manhour:import']"
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
                  v-hasPerm="['module_produce:manhour:export']"
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
                  v-hasPerm="['module_produce:manhour:query']"
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
        highlight-current-row
        class="data-table__content"
        border
        stripe
        @selection-change="handleSelectionChange"
        @sort-change="handleSortChange"
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
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'index')?.show"
          fixed
          label="序号"
          min-width="60"
          align="center"
        >
          <template #default="scope">
            {{ (queryFormData.page_no - 1) * queryFormData.page_size + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'name')?.show"
          label="名称"
          prop="name"
          min-width="180"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'model')?.show"
          label="型号"
          prop="model"
          min-width="120"
          header-align="center"
          show-overflow-tooltip
        />
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'material')?.show"
          label="材质"
          prop="material"
          min-width="140"
          show-overflow-tooltip
        /> -->
        <el-table-column
            v-if="tableColumns.find((col) => col.prop === 'unit')?.show"
            label="单位"
            prop="unit"
            align="center"
            min-width="70"
            show-overflow-tooltip
          >
            <template #default="scope">
              <el-tag v-if="scope.row.unit === 'g'" type="success">重量</el-tag>
              <el-tag v-else-if="scope.row.unit === 'm'" type="warning">长度</el-tag>
              <el-tag v-else-if="scope.row.unit === 'p'" type="info">件</el-tag>
              <span v-else>{{ scope.row.unit }}</span>
            </template>
          </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'unit_hour')?.show"
          label="工时"
          prop="unit_hour"
          header-align="center"
          min-width="80"
          show-overflow-tooltip
          sortable="custom"
        >
          <template #default="scope">
            {{ scope.row.unit_hour ? (Number(scope.row.unit_hour) / 3600000).toFixed(3) : 0 }}
          </template>
        </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'blanking_ratio')?.show"
          label="下料"
          prop="blanking_ratio"
          align="center"
          min-width="60"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'welding_ratio')?.show"
          label="铆焊"
          prop="welding_ratio"
          align="center"
          min-width="60"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'fitting_ratio')?.show"
          label="装配"
          prop="fitting_ratio"
          align="center"
          min-width="60"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'description')?.show"
          label="备注/描述"
          prop="description"
          header-align="center"
          min-width="140"
          show-overflow-tooltip
        />
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'created_time')?.show"
          label="创建时间"
          prop="created_time"
          min-width="140"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'updated_time')?.show"
          label="更新时间"
          prop="updated_time"
          min-width="140"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'created_id')?.show"
          label="创建人ID"
          prop="created_id"
          min-width="140"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'created_id')?.show"
          label="创建人ID"
          prop="created_id"
          min-width="140"
          show-overflow-tooltip
        >
          <template #default="scope">
            <el-tag>{{ scope.row.created_by?.name }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'updated_id')?.show"
          label="更新人ID"
          prop="updated_id"
          min-width="140"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'updated_id')?.show"
          label="更新人ID"
          prop="updated_id"
          min-width="140"
          show-overflow-tooltip
        >
          <template #default="scope">
            <el-tag>{{ scope.row.updated_by?.name }}</el-tag>
          </template>
        </el-table-column> -->
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'operation')?.show"
          fixed="right"
          label="操作"
          align="center"
          min-width="70"
        >
          <template #default="scope">
            <el-button
              v-hasPerm="['module_produce:manhour:detail']"
              type="info"
              size="small"
              link
              icon="document"
              @click="handleOpenDialog('detail', scope.row.id)"
            >
              详情
            </el-button>
            <!-- <el-button
              v-hasPerm="['module_produce:manhour:update']"
              type="primary"
              size="small"
              link
              icon="edit"
              @click="handleOpenDialog('update', scope.row.id)"
            >
              编辑
            </el-button> -->
            <!-- <el-button
              v-hasPerm="['module_produce:manhour:delete']"
              type="danger"
              size="small"
              link
              icon="delete"
              @click="handleDelete([scope.row.id])"
            >
              删除
            </el-button> -->
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页区域 -->
      <template #footer>
        <pagination
          v-model:total="total"
          v-model:page="queryFormData.page_no"
          v-model:limit="queryFormData.page_size"
          @pagination="loadingData"
        />
      </template>
    </el-card>

    <!-- 弹窗区域 -->
    <el-dialog
      v-model="dialogVisible.visible"
      :title="dialogVisible.title"
      @close="handleCloseDialog"
    >
      <!-- 详情 -->
      <template v-if="dialogVisible.type === 'detail'">
        <el-descriptions :column="4" border>
          <el-descriptions-item label="主键ID" :span="2">
            {{ detailFormData.id }}
          </el-descriptions-item>
          <el-descriptions-item label="零件名称" :span="2">
            {{ detailFormData.name }}
          </el-descriptions-item>
          <el-descriptions-item label="零件型号" :span="2">
            {{ detailFormData.model }}
          </el-descriptions-item>
          <el-descriptions-item label="材质" :span="2">
            {{ detailFormData.material }}
          </el-descriptions-item>
          <el-descriptions-item label="计算单位" :span="2">
            <el-tag v-if="detailFormData.unit === 'g'" type="success">重量 (g)</el-tag>
            <el-tag v-else-if="detailFormData.unit === 'm'" type="warning">长度 (m)</el-tag>
            <el-tag v-else-if="detailFormData.unit === 'p'" type="info">件 (p)</el-tag>
            <span v-else>{{ detailFormData.unit }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="单位工时 (小时)" :span="2">
            {{ detailFormData.unit_hour ? (Number(detailFormData.unit_hour) / 3600000).toFixed(3) : 0 }}
          </el-descriptions-item>
          <el-descriptions-item label="下料工时比率" :span="2">
            {{ detailFormData.blanking_ratio }}
          </el-descriptions-item>
          <el-descriptions-item label="铆焊工时比率" :span="2">
            {{ detailFormData.welding_ratio }}
          </el-descriptions-item>
          <el-descriptions-item label="装配工时比率" :span="2">
            {{ detailFormData.fitting_ratio }}
          </el-descriptions-item>
          <el-descriptions-item label="备注/描述" :span="2">
            {{ detailFormData.description }}
          </el-descriptions-item>
          <el-descriptions-item label="创建时间" :span="2">
            {{ detailFormData.created_time }}
          </el-descriptions-item>
          <el-descriptions-item label="更新时间" :span="2">
            {{ detailFormData.updated_time }}
          </el-descriptions-item>
          <el-descriptions-item label="创建人" :span="2">
            {{ detailFormData.created_by?.name }}
          </el-descriptions-item>
          <el-descriptions-item label="更新人" :span="2">
            {{ detailFormData.updated_by?.name }}
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
          <el-form-item label="零件名称" prop="name" :required="false">
            <el-input v-model="formData.name" placeholder="请输入零件名称" />
          </el-form-item>
          <el-form-item label="零件型号" prop="model" :required="false">
            <el-input v-model="formData.model" placeholder="请输入零件型号" />
          </el-form-item>
          <el-form-item label="材质" prop="material" :required="false">
            <el-input v-model="formData.material" placeholder="请输入材质" />
          </el-form-item>
          <el-form-item label="计算单位" prop="unit" :required="false">
            <el-select v-model="formData.unit" placeholder="请选择单位" clearable style="width: 100%">
              <el-option label="重量 (g)" value="g" />
              <el-option label="长度 (m)" value="m" />
              <el-option label="件 (p)" value="p" />
            </el-select>
          </el-form-item>
          <el-form-item label="单位工时ms" prop="unit_hour" :required="false">
            <el-input-number
              v-model="formData.unit_hour"
              placeholder="请输入单位工时 (毫秒)"
              style="width: 100%"
              :min="0"
              :precision="0"
            />
          </el-form-item>
          <el-form-item label="下料工时比率" prop="blanking_ratio" :required="false">
            <el-input-number
              v-model="formData.blanking_ratio"
              placeholder="请输入下料工时比率"
              style="width: 100%"
              :min="0"
            />
          </el-form-item>
          <el-form-item label="铆焊工时比率" prop="welding_ratio" :required="false">
            <el-input-number
              v-model="formData.welding_ratio"
              placeholder="请输入铆焊工时比率"
              style="width: 100%"
              :min="0"
            />
          </el-form-item>
          <el-form-item label="装配工时比率" prop="fitting_ratio" :required="false">
            <el-input-number
              v-model="formData.fitting_ratio"
              placeholder="请输入装配工时比率"
              style="width: 100%"
              :min="0"
            />
          </el-form-item>
          <el-form-item label="描述" prop="description">
            <el-input
              v-model="formData.description"
              :rows="4"
              :maxlength="100"
              show-word-limit
              type="textarea"
              placeholder="请输入描述"
            />
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
  name: "ProduceManhour",
  inheritAttrs: false,
});

import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { QuestionFilled, ArrowUp, ArrowDown, Check, CircleClose } from "@element-plus/icons-vue";
import { formatToDateTime } from "@/utils/dateUtil";
import { useDictStore } from "@/store";
import { ResultEnum } from "@/enums/api/result.enum";
import DatePicker from "@/components/DatePicker/index.vue";
import type { IContentConfig } from "@/components/CURD/types";
import ImportModal from "@/components/CURD/ImportModal.vue";
import ExportModal from "@/components/CURD/ExportModal.vue";
import ProduceManhourAPI, {
  ProduceManhourPageQuery,
  ProduceManhourTable,
  ProduceManhourForm,
} from "@/api/module_produce/manhour";

const visible = ref(true);
const queryFormRef = ref();
const dataFormRef = ref();
const total = ref(0);
const selectIds = ref<number[]>([]);
const selectionRows = ref<ProduceManhourTable[]>([]);
const loading = ref(false);
const isExpand = ref(false);
const isExpandable = ref(true);

// 分页表单
const pageTableData = ref<ProduceManhourTable[]>([]);

// 表格列配置
const tableColumns = ref([
  { prop: "selection", label: "选择框", show: true },
  { prop: "index", label: "序号", show: true },
  { prop: "name", label: "零件名称", show: true },
  { prop: "model", label: "零件型号", show: true },
  { prop: "material", label: "材质", show: true },
  { prop: "unit", label: "计算单位", show: true },
  { prop: "unit_hour", label: "工时 (小时)", show: true },
  { prop: "blanking_ratio", label: "下料工时比率", show: true },
  { prop: "welding_ratio", label: "铆焊工时比率", show: true },
  { prop: "fitting_ratio", label: "装配工时比率", show: true },
  { prop: "description", label: "备注/描述", show: true },
  { prop: "created_time", label: "创建时间", show: true },
  { prop: "updated_time", label: "更新时间", show: true },
  { prop: "created_id", label: "创建人ID", show: true },
  { prop: "updated_id", label: "更新人ID", show: true },
  { prop: "operation", label: "操作", show: true },
]);

// 导出列（不含选择/序号/操作）
const exportColumns = [
  { prop: "name", label: "零件名称" },
  { prop: "model", label: "零件型号" },
  { prop: "material", label: "材质" },
  { prop: "unit", label: "计算单位" },
  { prop: "unit_hour", label: "工时 (小时)" },
  { prop: "blanking_ratio", label: "下料工时比率" },
  { prop: "welding_ratio", label: "铆焊工时比率" },
  { prop: "fitting_ratio", label: "装配工时比率" },
  { prop: "description", label: "备注/描述" },
  { prop: "created_time", label: "创建时间" },
  { prop: "updated_time", label: "更新时间" },
  { prop: "created_id", label: "创建人ID" },
  { prop: "updated_id", label: "更新人ID" },
];

// 导入/导出配置
const curdContentConfig = {
  permPrefix: "module_produce:manhour",
  cols: exportColumns as any,
  importTemplate: () => ProduceManhourAPI.downloadTemplateProduceManhour(),
  exportsAction: async (params: any) => {
    const query: any = { ...params };
    query.status = "0";
    query.page_no = 1;
    query.page_size = 9999;
    const all: any[] = [];
    while (true) {
      const res = await ProduceManhourAPI.listProduceManhour(query);
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
const detailFormData = ref<ProduceManhourTable>({});
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
const queryFormData = reactive<ProduceManhourPageQuery>({
  page_no: 1,
  page_size: 10,
  name: undefined,
  model: undefined,
  material: undefined,
  unit: undefined,
  unit_hour: undefined,
  blanking_ratio: undefined,
  welding_ratio: undefined,
  fitting_ratio: undefined,
  created_time: undefined,
  updated_time: undefined,
  created_id: undefined,
  updated_id: undefined,
  order_by: undefined,
});

// 排序处理
function handleSortChange({ prop, order }: { prop: string; order: string | null }) {
  if (prop && order) {
    const direction = order === "ascending" ? "asc" : "desc";
    queryFormData.order_by = JSON.stringify([{ [prop]: direction }]);
  } else {
    queryFormData.order_by = undefined;
  }
  handleQuery();
}

// 编辑表单
const formData = reactive<ProduceManhourForm>({
  id: undefined,
  name: undefined,
  model: undefined,
  material: undefined,
  unit: undefined,
  unit_hour: undefined,
  blanking_ratio: undefined,
  welding_ratio: undefined,
  fitting_ratio: undefined,
  description: undefined,
});

// 字典仓库与需要加载的字典类型
const dictStore = useDictStore();
const dictTypes: any = [
];

// 弹窗状态
const dialogVisible = reactive({
  title: "",
  visible: false,
  type: "create" as "create" | "update" | "detail",
});

// 表单验证规则
const rules = reactive({
  id: [{ required: false, message: "请输入主键ID", trigger: "blur" }],
  name: [{ required: false, message: "请输入零件名称", trigger: "blur" }],
  model: [{ required: true, message: "请输入零件型号", trigger: "blur" }],
  material: [{ required: true, message: "请输入材质", trigger: "blur" }],
  unit: [{ required: false, message: "请选择计算单位", trigger: "change" }],
  unit_hour: [{ required: false, message: "请输入单位工时ms", trigger: "blur" }],
  blanking_ratio: [{ required: true, message: "请输入下料工时比率", trigger: "blur" }],
  welding_ratio: [{ required: true, message: "请输入铆焊工时比率", trigger: "blur" }],
  fitting_ratio: [{ required: true, message: "请输入装配工时比率", trigger: "blur" }],
  description: [{ required: true, message: "请输入备注/描述", trigger: "blur" }],
  created_time: [{ required: false, message: "请输入创建时间", trigger: "blur" }],
  updated_time: [{ required: false, message: "请输入更新时间", trigger: "blur" }],
  created_id: [{ required: true, message: "请输入创建人ID", trigger: "blur" }],
  updated_id: [{ required: true, message: "请输入更新人ID", trigger: "blur" }],
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
async function loadingData() {
  loading.value = true;
  try {
    const response = await ProduceManhourAPI.listProduceManhour(queryFormData);
    pageTableData.value = response.data.data.items;
    total.value = response.data.data.total;
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

// 选择创建人后触发查询
function handleConfirm() {
  handleQuery();
}

// 重置查询
async function handleResetQuery() {
  queryFormRef.value.resetFields();
  queryFormData.page_no = 1;
  queryFormData.order_by = undefined;
  // 重置日期范围选择器
  createdDateRange.value = [];
  updatedDateRange.value = [];
  queryFormData.created_time = undefined;
  queryFormData.updated_time = undefined;
  // 重置表格排序
  if (tableRef.value) {
    tableRef.value.clearSort();
  }
  loadingData();
}

// 定义初始表单数据常量
const initialFormData: ProduceManhourForm = {
  id: undefined,
  name: undefined,
  model: undefined,
  material: undefined,
  unit: undefined,
  unit_hour: undefined,
  blanking_ratio: undefined,
  welding_ratio: undefined,
  fitting_ratio: undefined,
  description: undefined,
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
    const response = await ProduceManhourAPI.detailProduceManhour(id);
    if (type === "detail") {
      dialogVisible.title = "详情";
      Object.assign(detailFormData.value, response.data.data);
    } else if (type === "update") {
      dialogVisible.title = "修改";
      Object.assign(formData, response.data.data);
    }
  } else {
    dialogVisible.title = "新增ProduceManhour";
    formData.id = undefined;
    formData.name = undefined;
    formData.model = undefined;
    formData.material = undefined;
    formData.unit = undefined;
    formData.unit_hour = undefined;
    formData.blanking_ratio = undefined;
    formData.welding_ratio = undefined;
    formData.fitting_ratio = undefined;
    formData.description = undefined;
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
          await ProduceManhourAPI.updateProduceManhour(id, { id, ...submitData });
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
          await ProduceManhourAPI.createProduceManhour(submitData);
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
        await ProduceManhourAPI.deleteProduceManhour(ids);
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
          await ProduceManhourAPI.batchProduceManhour({ ids: selectIds.value, status });
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
    const response = await ProduceManhourAPI.importProduceManhour(formData);
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
  loadingData();
});
</script>

<style lang="scss" scoped></style>
