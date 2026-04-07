<!-- BOM清单 -->
<template>
  <div class="app-container">
    <!-- 内容区域 -->
    <el-card class="data-table">
      <template #header>
        <!-- <div class="card-header">
          <span>
            BOM清单列表
            <el-tooltip content="BOM清单列表">
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
            <!-- <el-form-item label="父代号" prop="parent_code">
              <el-input
                v-model="queryFormData.parent_code"
                placeholder="请输入父代号"
                clearable
                style="width: 110px"
              />
            </el-form-item> -->
            <el-form-item label="代号" prop="code">
              <el-input
                v-model="queryFormData.code"
                placeholder="请输入代号"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <el-form-item label="名称" prop="spec">
              <el-input
                v-model="queryFormData.spec"
                placeholder="请输入名称"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <!-- <el-form-item label="数量" prop="count">
              <el-input v-model="queryFormData.count" placeholder="请输入数量" clearable />
            </el-form-item> -->
            <el-form-item label="材质" prop="material">
              <el-input
                v-model="queryFormData.material"
                placeholder="请输入材质"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <!-- <el-form-item label="单重" prop="unit_mass">
              <el-input v-model="queryFormData.unit_mass" placeholder="请输入单重" clearable />
            </el-form-item> -->
            <!-- <el-form-item label="总重" prop="total_mass">
              <el-input v-model="queryFormData.total_mass" placeholder="请输入总重" clearable />
            </el-form-item> -->
            <el-form-item label="备注" prop="remark">
              <el-input
                v-model="queryFormData.remark"
                placeholder="请输入备注"
                clearable
                style="width: 100px"
              />
            </el-form-item>
            <!-- <el-form-item prop="status" label="状态" style="width: 120px">
              <el-select
                v-model="queryFormData.status"
                placeholder="选择"
                style="width: 170px"
                clearable
              >
                <el-option value="0" label="启用" />
                <el-option value="1" label="停用" />
              </el-select>
            </el-form-item> -->
            <!-- <el-form-item v-if="isExpand" prop="created_time" label="创建时间">
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
                v-hasPerm="['module_data:bom:query']"
                type="primary"
                icon="search"
                @click="handleQuery"
              >
                查询
              </el-button>
              <el-button
                v-hasPerm="['module_data:bom:query']"
                icon="refresh"
                @click="handleResetQuery"
              >
                重置
              </el-button>
              <el-button type="info" plain icon="Expand" @click="toggleAllExpansion(true)">
                全部展开
              </el-button>
              <el-button type="info" plain icon="Fold" @click="toggleAllExpansion(false)">
                全部收起
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
              </template>
              <div>&nbsp;&nbsp;</div> -->
              <el-button
                v-if="allParsedBoms.length > 0"
                v-hasPerm="['module_data:file:create']"
                type="warning"
                icon="Checked"
                native-type="button"
                @click="handleSaveData"
              >
                保存数据
              </el-button>
              <el-button
                v-hasPerm="['module_data:file:create']"
                type="success"
                icon="plus"
                @click="handleUploadFile"
              >
                上传文件
              </el-button>
              <el-button
                v-if="tableSourceData.info.length > 0"
                type="info"
                icon="document"
                @click="logDrawerVisible = true"
              >
                查看日志
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
                v-hasPerm="['module_data:bom:create']"
                type="success"
                icon="plus"
                @click="handleOpenDialog('create')"
              >
                新增
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-button
                v-hasPerm="['module_data:bom:delete']"
                type="danger"
                icon="delete"
                :disabled="selectIds.length === 0"
                @click="handleDelete(selectIds)"
              >
                批量删除
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-dropdown v-hasPerm="['module_data:bom:batch']" trigger="click">
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
                  v-hasPerm="['module_data:bom:import']"
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
                  v-hasPerm="['module_data:bom:export']"
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
                  v-hasPerm="['module_data:bom:query']"
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

      <!-- 导入结果展示抽屉 -->
      <el-drawer v-model="logDrawerVisible" title="文件解析日志" direction="rtl" size="50%">
        <div style="margin-bottom: 20px">
          <el-descriptions title="项目信息" :column="4" border>
            <el-descriptions-item label="合同号" :span="1">
              {{ tableSourceData.project_no }}
            </el-descriptions-item>
            <el-descriptions-item label="项目代号" :span="3">
              {{ tableSourceData.project_code }}
            </el-descriptions-item>
            <el-descriptions-item label="文件个数" :span="1">
              {{ tableSourceData.file_count }}
            </el-descriptions-item>
            <el-descriptions-item label="项目名称" :span="3">
              {{ tableSourceData.project_name }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <div class="log-title" style="font-weight: bold; margin-bottom: 10px; font-size: 16px">
          解析详情：
        </div>
        <div
          v-for="(text, index) in tableSourceData?.info"
          :key="index"
          class="text-line"
          style="font-size: 15px; margin-bottom: 8px; padding: 4px; border-bottom: 1px solid #eee"
          v-html="text"
        ></div>
      </el-drawer>

      <!-- 表格区域：系统配置列表 -->
      <el-table
        ref="tableRef"
        v-loading="loading"
        :data="pageTableData"
        row-key="_tree_id"
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
        </el-table-column> -->
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'parent_code')?.show"
          label="父代号"
          prop="parent_code"
          min-width="130"
          header-align="center"
          show-overflow-tooltip
        /> -->
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'code')?.show"
          label="代号"
          prop="code"
          min-width="200"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'spec')?.show"
          label="名称"
          prop="spec"
          min-width="140"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'count')?.show"
          label="数量"
          prop="count"
          min-width="50"
          align="center"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'material')?.show"
          label="材质"
          prop="material"
          min-width="100"
          header-align="center"
          show-overflow-tooltip
        />
        <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'unit_mass')?.show"
          label="单重"
          prop="unit_mass"
          min-width="60"
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
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'status')?.show"
          label="状态"
          prop="status"
          min-width="55"
          align="center"
          header-align="center"
          show-overflow-tooltip
        >
          <template #default="scope">
            <el-tag :type="scope.row.status == '0' ? 'success' : 'info'">
              {{ scope.row.status == "0" ? "启用" : "停用" }}
            </el-tag>
          </template>
        </el-table-column> -->
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'description')?.show"
          label="备注/描述"
          prop="description"
          min-width="140"
          show-overflow-tooltip
        />
        <el-table-column
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
        <!-- <el-table-column
          v-if="tableColumns.find((col) => col.prop === 'operation')?.show"
          fixed="right"
          label="操作"
          align="center"
          min-width="200"
        >
          <template #default="scope">
            <el-button
              v-hasPerm="['module_data:bom:detail']"
              type="info"
              size="small"
              link
              icon="document"
              @click="handleOpenDialog('detail', scope.row.id)"
            >
              详情
            </el-button>
            <el-button
              v-hasPerm="['module_data:bom:update']"
              type="primary"
              size="small"
              link
              icon="edit"
              @click="handleOpenDialog('update', scope.row.id)"
            >
              编辑
            </el-button>
            <el-button
              v-hasPerm="['module_data:bom:delete']"
              type="danger"
              size="small"
              link
              icon="delete"
              @click="handleDelete([scope.row.id])"
            >
              删除
            </el-button>
          </template>
        </el-table-column> -->
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
          <el-descriptions-item label="父代号" :span="2">
            {{ detailFormData.parent_code }}
          </el-descriptions-item>
          <el-descriptions-item label="数量" :span="2">
            {{ detailFormData.count }}
          </el-descriptions-item>
          <el-descriptions-item label="代号" :span="2">
            {{ detailFormData.code }}
          </el-descriptions-item>
          <el-descriptions-item label="单重" :span="2">
            {{ detailFormData.unit_mass }}
          </el-descriptions-item>
          <el-descriptions-item label="名称" :span="2">
            {{ detailFormData.spec }}
          </el-descriptions-item>
          <el-descriptions-item label="总重" :span="2">
            {{ detailFormData.total_mass }}
          </el-descriptions-item>
          <el-descriptions-item label="材质" :span="2">
            {{ detailFormData.material }}
          </el-descriptions-item>
          <el-descriptions-item label="状态" :span="2">
            <el-tag :type="detailFormData.status == '0' ? 'success' : 'danger'">
              {{ detailFormData.status == "0" ? "启用" : "停用" }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">
            {{ detailFormData.remark }}
          </el-descriptions-item>
          <el-descriptions-item label="是否借用" :span="2">
            {{ detailFormData.borrow ? "是" : "否" }}
          </el-descriptions-item>
          <el-descriptions-item label="是否外购" :span="2">
            {{ detailFormData.procure ? "是" : "否" }}
          </el-descriptions-item>
          <el-descriptions-item label="是否无图" :span="2">
            {{ detailFormData.noimage ? "是" : "否" }}
          </el-descriptions-item>
          <el-descriptions-item label="是否附图" :span="2">
            {{ detailFormData.figure ? "是" : "否" }}
          </el-descriptions-item>
          <el-descriptions-item label="创建人" :span="2">
            {{ detailFormData.created_by?.name }}
          </el-descriptions-item>
          <el-descriptions-item label="创建时间" :span="2">
            {{ detailFormData.created_time }}
          </el-descriptions-item>
          <!-- <el-descriptions-item label="备注/描述" :span="2">
            {{ detailFormData.description }}
          </el-descriptions-item> -->
          <el-descriptions-item label="更新人" :span="2">
            {{ detailFormData.updated_by?.name }}
          </el-descriptions-item>
          <el-descriptions-item label="更新时间" :span="2">
            {{ detailFormData.updated_time }}
          </el-descriptions-item>
          <el-descriptions-item label="UUID" :span="2">
            {{ detailFormData.uuid }}
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
          <el-form-item label="父代号" prop="parent_code" :required="true">
            <el-input v-model="formData.parent_code" placeholder="请输入父代号" />
          </el-form-item>
          <el-form-item label="代号" prop="code" :required="false">
            <el-input v-model="formData.code" placeholder="请输入代号" />
          </el-form-item>
          <el-form-item label="名称" prop="spec" :required="true">
            <el-input v-model="formData.spec" placeholder="请输入名称" />
          </el-form-item>
          <el-form-item label="数量" prop="count" :required="true">
            <el-input v-model="formData.count" placeholder="请输入数量" />
          </el-form-item>
          <el-form-item label="材质" prop="material" :required="false">
            <el-input v-model="formData.material" placeholder="请输入材质" />
          </el-form-item>
          <el-form-item label="单重" prop="unit_mass" :required="false">
            <el-input v-model="formData.unit_mass" placeholder="请输入单重" />
          </el-form-item>
          <el-form-item label="总重" prop="total_mass" :required="false">
            <el-input v-model="formData.total_mass" placeholder="请输入总重" />
          </el-form-item>
          <el-form-item label="备注" prop="remark" :required="false">
            <el-input v-model="formData.remark" placeholder="请输入备注" />
          </el-form-item>
          <el-form-item label="状态" prop="status" :required="true">
            <el-radio-group v-model="formData.status">
              <el-radio value="0">启用</el-radio>
              <el-radio value="1">停用</el-radio>
            </el-radio-group>
          </el-form-item>
          <!-- <el-form-item label="描述" prop="description">
            <el-input
              v-model="formData.description"
              :rows="4"
              :maxlength="100"
              show-word-limit
              type="textarea"
              placeholder="请输入描述"
            />
          </el-form-item> -->
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
    <!-- 上传对话框 -->
    <el-dialog
      v-model="uploadDialogVisible"
      title="上传文件"
      width="500px"
      :before-close="handleUploadClose"
    >
      <el-upload
        ref="uploadRef"
        :auto-upload="false"
        :multiple="true"
        :file-list="uploadFileList"
        drag
        @change="handleUploadChange"
      >
        <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或
          <em>点击上传</em>
        </div>
        <template #tip>
          <div class="el-upload__tip" style="color: red">
            不支持多文件上传，单个文件不超过100MB，多文件上传，取最后一个文件上传
          </div>
        </template>
      </el-upload>
      <template #footer>
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button
          v-hasPerm="['module_monitor:resource:upload']"
          type="primary"
          :loading="uploading"
          @click="handleUploadConfirm"
        >
          确定上传
        </el-button>
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
  name: "DataBom",
  inheritAttrs: false,
});

import { ref, reactive, onMounted, watch } from "vue";
import { useDebounceFn } from "@vueuse/core";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  QuestionFilled,
  ArrowUp,
  ArrowDown,
  Check,
  CircleClose,
  Expand,
  Fold,
} from "@element-plus/icons-vue";
import { formatToDateTime } from "@/utils/dateUtil";
import { useDictStore } from "@/store";
import { ResultEnum } from "@/enums/api/result.enum";
import DatePicker from "@/components/DatePicker/index.vue";
import type { IContentConfig } from "@/components/CURD/types";
import ImportModal from "@/components/CURD/ImportModal.vue";
import ExportModal from "@/components/CURD/ExportModal.vue";
import DataBomAPI, { DataBomPageQuery, DataBomTable, DataBomForm } from "@/api/module_data/bom";
import FileAPI from "@/api/module_data/file";
import { convertToTree } from "../utils";

const visible = ref(true);
const tableRef = ref();
const queryFormRef = ref();
const dataFormRef = ref();
const total = ref(0);
const selectIds = ref<number[]>([]);
const selectionRows = ref<DataBomTable[]>([]);
const loading = ref(false);
const isExpand = ref(false);
const isExpandable = ref(true);

// 分页表单
const pageTableData = ref<DataBomTable[]>([]);
const allParsedBoms = ref<any[]>([]); // 存储解析后的扁平原始数据

// 表格列配置
const tableColumns = ref([
  { prop: "selection", label: "选择框", show: true },
  { prop: "index", label: "序号", show: false },
  { prop: "parent_code", label: "父代号", show: false },
  { prop: "first_code", label: "根代号", show: false },
  { prop: "code", label: "代号", show: true },
  { prop: "spec", label: "名称", show: true },
  { prop: "count", label: "数量", show: true },
  { prop: "material", label: "材质", show: true },
  { prop: "unit_mass", label: "单重", show: true },
  { prop: "total_mass", label: "总重", show: true },
  { prop: "remark", label: "备注", show: true },
  { prop: "status", label: "是否启用(0:启用 1:禁用)", show: true },
  { prop: "description", label: "备注/描述", show: false },
  { prop: "created_time", label: "创建时间", show: false },
  { prop: "updated_time", label: "更新时间", show: false },
  { prop: "created_id", label: "创建人ID", show: false },
  { prop: "updated_id", label: "更新人ID", show: false },
  { prop: "operation", label: "操作", show: true },
]);

// 导出列（不含选择/序号/操作）
const exportColumns = [
  { prop: "parent_code", label: "父代号" },
  { prop: "first_code", label: "根代号" },
  { prop: "code", label: "代号" },
  { prop: "spec", label: "名称" },
  { prop: "count", label: "数量" },
  { prop: "material", label: "材质" },
  { prop: "unit_mass", label: "单重" },
  { prop: "total_mass", label: "总重" },
  { prop: "remark", label: "备注" },
  { prop: "status", label: "是否启用(0:启用 1:禁用)" },
  { prop: "description", label: "备注/描述" },
  { prop: "created_time", label: "创建时间" },
  { prop: "updated_time", label: "更新时间" },
  { prop: "created_id", label: "创建人ID" },
  { prop: "updated_id", label: "更新人ID" },
];

// 导入/导出配置
const curdContentConfig = {
  permPrefix: "module_data:bom",
  cols: exportColumns as any,
  importTemplate: () => DataBomAPI.downloadTemplateDataBom(),
  exportsAction: async (params: any) => {
    const query: any = { ...params };
    query.status = "0";
    query.page_no = 1;
    query.page_size = 9999;
    const all: any[] = [];
    while (true) {
      const res = await DataBomAPI.listDataBom(query);
      const items = (res.data?.data as any)?.items || [];
      const total = (res.data?.data as any)?.total || 0;
      all.push(...items);
      if (all.length >= total || items.length === 0) break;
      query.page_no += 1;
    }
    return all;
  },
} as unknown as IContentConfig;

// 详情表单
const detailFormData = ref<DataBomTable>({});
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
const queryFormData = reactive<DataBomPageQuery>({
  page_no: 1,
  page_size: 10,
  parent_code: undefined,
  code: undefined,
  spec: undefined,
  count: undefined,
  material: undefined,
  unit_mass: undefined,
  total_mass: undefined,
  remark: undefined,
  status: undefined,
  created_time: undefined,
  updated_time: undefined,
  created_id: undefined,
  updated_id: undefined,
});

// 编辑表单
const formData = reactive<DataBomForm>({
  id: undefined,
  parent_code: undefined,
  code: undefined,
  spec: undefined,
  count: undefined,
  material: undefined,
  unit_mass: undefined,
  total_mass: undefined,
  remark: undefined,
  status: undefined,
  description: undefined,
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
  // id: [{ required: false, message: "请输入主键ID", trigger: "blur" }],
  parent_code: [{ required: true, message: "请输入父代号", trigger: "blur" }],
  code: [{ required: false, message: "请输入代号", trigger: "blur" }],
  spec: [{ required: true, message: "请输入名称", trigger: "blur" }],
  count: [{ required: true, message: "请输入数量", trigger: "blur" }],
  material: [{ required: false, message: "请输入材质", trigger: "blur" }],
  unit_mass: [{ required: false, message: "请输入单重", trigger: "blur" }],
  total_mass: [{ required: false, message: "请输入总重", trigger: "blur" }],
  remark: [{ required: false, message: "请输入备注", trigger: "blur" }],
  // uuid: [{ required: false, message: "请输入UUID", trigger: "blur" }],
  status: [{ required: false, message: "请输入是否启用", trigger: "blur" }],
  description: [{ required: false, message: "请输入描述", trigger: "blur" }],
  // created_time: [{ required: false, message: "请输入创建时间", trigger: "blur" }],
  // updated_time: [{ required: false, message: "请输入更新时间", trigger: "blur" }],
  // created_id: [{ required: true, message: "请输入创建人ID", trigger: "blur" }],
  // updated_id: [{ required: true, message: "请输入更新人ID", trigger: "blur" }],
});

// 导入弹窗显示状态
const importDialogVisible = ref(false);
const uploadLoading = ref(false);

// 导出弹窗显示状态
const exportsDialogVisible = ref(false);

// 上传相关数据
const uploadDialogVisible = ref(false);
const uploadFileList = ref<any[]>([]);
const uploading = ref(false);
// 解析结果
const tableSourceData = ref<any>({
  info: [],
  project_code: "",
  project_name: "",
  project_no: "",
  first_code: "",
  file_count: 0,
});
const logDrawerVisible = ref(false);
// 路径相关数据
const currentPath = ref("/"); // 当前路径的响应式变量
// 打开上传对话框
function handleUploadFile() {
  uploadDialogVisible.value = true;
  uploadFileList.value = [];
}
// 关闭上传对话框
function handleUploadClose() {
  uploadDialogVisible.value = false;
  uploadFileList.value = [];
}
// 上传文件变化处理
function handleUploadChange(file: any, fileList: any[]) {
  uploadFileList.value = fileList;
}
// 确认上传文件
async function handleUploadConfirm() {
  if (uploadFileList.value.length === 0) {
    ElMessage.warning("请选择要上传的文件");
    return;
  }

  try {
    uploading.value = true;
    const formData = new FormData();
    uploadFileList.value.forEach((file: any) => {
      formData.append("file", file.raw);
    });

    // 在根目录时传递空字符串作为target_path，与后端relative_path格式保持一致
    const targetPath = currentPath.value === "/" ? "" : currentPath.value;
    formData.append("target_path", targetPath);

    const res = await FileAPI.uploadFile(formData);
    // console.log(res)

    if (res.data.success) {
      const resultData = res.data.data;
      // 把boms传递给boms表格显示
      const rawBoms = resultData.boms || [];
      allParsedBoms.value = rawBoms; // 保存扁平原始数据，用于本地搜索

      const { tree, errors } = convertToTree(
        rawBoms,
        resultData.project_code,
        resultData.first_code
      );
      pageTableData.value = tree;

      // 把项目信息和log传给文件解析日志显示
      tableSourceData.value.project_code = resultData.project_code || "";
      tableSourceData.value.project_name = resultData.project_name || "";
      tableSourceData.value.project_no = resultData.project_no || "";
      tableSourceData.value.first_code = resultData.first_code || "";
      tableSourceData.value.file_count = resultData.file_count || 0;

      let logs: string[] = [];
      if (resultData.log && Array.isArray(resultData.log)) {
        logs = resultData.log.map((item: any) => {
          return `[${item.status}] <span style="color: red">${item.msg}</span> 
            ${` (${item.bom?.code}, ${item.bom?.spec}, ${item.bom?.remark})`}`;
        });
      }

      // 合并后端日志和前端结构校验错误
      tableSourceData.value.info = [...logs, ...errors];

      if (tableSourceData.value.info.length === 0) {
        tableSourceData.value.info = ["解析完成，无日志记录"];
      }
      logDrawerVisible.value = true; // 显示文件解析日志窗口
    }

    uploadDialogVisible.value = false;
  } catch (error: any) {
    console.error("Upload error:", error);
  } finally {
    uploading.value = false;
  }
}

// 保存解析后的数据到数据库
async function handleSaveData() {
  if (allParsedBoms.value.length === 0) {
    ElMessage.warning("没有可保存的数据");
    return;
  }

  try {
    await ElMessageBox.confirm("确定要将当前解析出的数据保存到数据库吗？", "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    loading.value = true;
    const payload = {
      project: {
        name: tableSourceData.value.project_name,
        code: tableSourceData.value.project_code,
        no: tableSourceData.value.project_no,
      },
      bom: allParsedBoms.value,
    };

    const res = await FileAPI.saveData(payload);
    // 如果没有抛出异常，说明 res.data.code === ResultEnum.SUCCESS
    const resultData = res.data.data;

    // 1. 更新日志列表
    const saveLogHeader = `[保存成功] <span style="color: green; font-weight: bold;">数据已成功入库 (新增项目: ${resultData.project_added}, 新增BOM: ${resultData.bom_added})</span>`;

    // 强制触发更新，确保响应式
    const newInfo = [saveLogHeader, ...tableSourceData.value.info];
    tableSourceData.value = {
      ...tableSourceData.value,
      info: newInfo,
    };

    // 2. 打开抽屉并提示
    logDrawerVisible.value = true;
    ElMessage.success(`保存成功！新增BOM: ${resultData.bom_added} 条`);

    // 3. 保存成功后清空解析状态
    allParsedBoms.value = [];
    pageTableData.value = [];
  } catch (error: any) {
    if (error !== "cancel") {
      console.error("Save data error:", error);

      // 尝试从 error.response（Axios错误）获取数据
      const backendData = error.response?.data?.data;
      const duplicateCount = backendData?.duplicate_count || 0;

      if (duplicateCount > 0) {
        const saveLogHeader = `[保存失败] <span style="color: red; font-weight: bold;">发现 ${duplicateCount} 条重复记录，本次操作已回滚</span>`;
        tableSourceData.value.info.unshift(saveLogHeader, ...backendData.duplicate_logs);
        logDrawerVisible.value = true;
      } else if (error.message && error.message.includes("重复")) {
        // 如果拦截器返回的是纯 Error 对象且消息中包含"重复"，从消息解析数量
        const match = error.message.match(/(\d+)/);
        const count = match ? match[1] : "未知";
        const saveLogHeader = `[保存失败] <span style="color: red; font-weight: bold;">发现 ${count} 条重复记录，本次操作已回滚</span>`;
        tableSourceData.value.info.unshift(saveLogHeader);
        logDrawerVisible.value = true;
      }
    }
  } finally {
    loading.value = false;
  }
}

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
  // await loadingData(); // 不再自动刷新数据库数据
}

// 展开/收起所有行
function toggleAllExpansion(expanded: boolean) {
  const toggle = (nodes: any[]) => {
    nodes.forEach((node) => {
      tableRef.value?.toggleRowExpansion(node, expanded);
      if (node.children) {
        toggle(node.children);
      }
    });
  };
  toggle(pageTableData.value);
}

// 加载表格数据
async function loadingData() {
  // 仅执行本地搜索，不请求后端 API
  loading.value = true;
  try {
    const codeSearch = queryFormData.code?.toLowerCase() || "";
    const specSearch = queryFormData.spec?.toLowerCase() || "";
    const materialSearch = queryFormData.material?.toLowerCase() || "";
    const remarkSearch = queryFormData.remark?.toLowerCase() || "";

    // 如果没有任何搜索条件且没有数据，直接返回
    if (
      !codeSearch &&
      !specSearch &&
      !materialSearch &&
      !remarkSearch &&
      allParsedBoms.value.length === 0
    ) {
      pageTableData.value = [];
      return;
    }

    // 过滤匹配的节点
    const filtered = allParsedBoms.value.filter((item) => {
      const matchCode = !codeSearch || item.code?.toLowerCase().includes(codeSearch);
      const matchSpec = !specSearch || item.spec?.toLowerCase().includes(specSearch);
      const matchMaterial =
        !materialSearch || item.material?.toLowerCase().includes(materialSearch);
      const matchRemark = !remarkSearch || item.remark?.toLowerCase().includes(remarkSearch);
      return matchCode && matchSpec && matchMaterial && matchRemark;
    });

    // 为了保证树形结构的完整性，需要补充匹配节点的父节点
    const matchedCodes = new Set(filtered.map((item) => item.code));
    const finalBoms = new Set(filtered);

    // 递归寻找所有匹配项的父节点
    const addParents = (bom: any) => {
      if (bom.parent_code) {
        const parent = allParsedBoms.value.find((p) => p.code === bom.parent_code);
        if (parent && !matchedCodes.has(parent.code)) {
          finalBoms.add(parent);
          matchedCodes.add(parent.code);
          addParents(parent);
        }
      }
    };

    filtered.forEach(addParents);

    // 重新转换为树形结构展示
    pageTableData.value = convertToTree(
      Array.from(finalBoms),
      tableSourceData.value.project_code,
      tableSourceData.value.first_code
    ).tree;
  } finally {
    loading.value = false;
  }
}

// 防抖查询
const debouncedSearch = useDebounceFn(() => {
  handleQuery();
}, 500);

// 监听搜索参数变化
watch(
  () => [
    queryFormData.parent_code,
    queryFormData.code,
    queryFormData.spec,
    queryFormData.material,
    queryFormData.remark,
    queryFormData.status,
    queryFormData.created_time,
    queryFormData.updated_time,
    queryFormData.created_id,
    queryFormData.updated_id,
  ],
  () => {
    debouncedSearch();
  }
);

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
  // 重置日期范围选择器
  createdDateRange.value = [];
  updatedDateRange.value = [];
  queryFormData.created_time = undefined;
  queryFormData.updated_time = undefined;

  // 如果有解析过的数据，恢复显示全部解析数据，而不是清空
  if (allParsedBoms.value.length > 0) {
    loadingData();
  } else {
    pageTableData.value = [];
  }
}

// 定义初始表单数据常量
const initialFormData: DataBomForm = {
  id: undefined,
  parent_code: undefined,
  code: undefined,
  spec: undefined,
  count: undefined,
  material: undefined,
  unit_mass: undefined,
  total_mass: undefined,
  remark: undefined,
  status: undefined,
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
    const response = await DataBomAPI.detailDataBom(id);
    if (type === "detail") {
      dialogVisible.title = "详情";
      Object.assign(detailFormData.value, response.data.data);
    } else if (type === "update") {
      dialogVisible.title = "修改";
      Object.assign(formData, response.data.data);
    }
  } else {
    dialogVisible.title = "新增DataBom";
    formData.id = undefined;
    formData.parent_code = undefined;
    formData.code = undefined;
    formData.spec = undefined;
    formData.count = undefined;
    formData.material = undefined;
    formData.unit_mass = undefined;
    formData.total_mass = undefined;
    formData.remark = undefined;
    formData.status = undefined;
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
          await DataBomAPI.updateDataBom(id, { id, ...submitData });
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
          await DataBomAPI.createDataBom(submitData);
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
        await DataBomAPI.deleteDataBom(ids);
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
          await DataBomAPI.batchDataBom({ ids: selectIds.value, status });
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
    const response = await DataBomAPI.importDataBom(formData);
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
  // loadingData(); // 默认不加载数据，等待文件上传解析结果
});
</script>

<style lang="scss" scoped></style>
