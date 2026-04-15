<!-- BOM清单搜索组件 -->
<template>
  <div class="search-container">
    <el-form
      ref="queryFormRef"
      :model="modelValue"
      label-suffix=":"
      label-width="auto"
      :inline="true"
      @submit.prevent="$emit('search')"
    >
      <el-form-item label="代号" prop="code">
        <el-input
          v-model="modelValue.code"
          placeholder="请输入代号"
          clearable
          style="width: 100px"
          @keyup.enter="$emit('search')"
        />
      </el-form-item>
      <el-form-item label="名称" prop="spec">
        <el-input
          v-model="modelValue.spec"
          placeholder="请输入名称"
          clearable
          style="width: 100px"
          @keyup.enter="$emit('search')"
        />
      </el-form-item>
      <el-form-item label="材质" prop="material">
        <el-input
          v-model="modelValue.material"
          placeholder="请输入材质"
          clearable
          style="width: 100px"
          @keyup.enter="$emit('search')"
        />
      </el-form-item>
      <el-form-item label="备注" prop="remark">
        <el-input
          v-model="modelValue.remark"
          placeholder="请输入备注"
          clearable
          style="width: 100px"
          @keyup.enter="$emit('search')"
        />
      </el-form-item>
      <!-- 查询、重置、展开/收起按钮 -->
      <el-form-item>
        <el-button
          v-hasPerm="['module_data:bom:query']"
          icon="refresh"
          @click="$emit('reset')"
        >
          重置
        </el-button>
        <div>&nbsp;&nbsp;</div>
        <el-button type="info" plain icon="Expand" @click="$emit('toggle-expand', true)">
          展开
        </el-button>
        <el-button type="info" plain icon="Fold" @click="$emit('toggle-expand', false)">
          收起
        </el-button>
        <el-button v-if="showProjectBtn" type="primary" icon="Collection" @click="$emit('open-project')">
          项目
        </el-button>
        <slot name="extra"></slot>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import type { DataBomQuery } from "@/api/module_data/bom";

// 1. 先定义清楚类型结构
interface Props {
  modelValue: DataBomQuery;
  showProjectBtn?: boolean;
}

// 2. 一次性定义 Props 并设置默认值
const props = withDefaults(defineProps<Props>(), {
  showProjectBtn: true,
});

defineEmits<{
  (e: "search"): void;
  (e: "reset"): void;
  (e: "toggle-expand", expanded: boolean): void;
  (e: "open-project"): void;
}>();
</script>

<style lang="scss" scoped>
.search-container {
  // 1. 缩小 Label 和 Input 之间的距离
  :deep(.el-form-item__label) {
    padding-right: 5px !important; // 默认通常是 12px，改为 4px 甚至更小
  }

  // 2. 如果你觉得两个输入框（Item）之间也太远，可以顺便调整这个
  :deep(.el-form-item) {
    margin-right: 15px !important; // 默认通常是 18px 或 32px
  }
}
</style>
