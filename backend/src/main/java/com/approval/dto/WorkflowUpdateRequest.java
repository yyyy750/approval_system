package com.approval.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 更新工作流请求DTO
 */
@Data
public class WorkflowUpdateRequest {

    /**
     * 模板名称
     */
    @NotBlank(message = "模板名称不能为空")
    private String name;

    /**
     * 模板描述
     */
    private String description;

    /**
     * 状态: 0-禁用 1-启用
     */
    private Integer status;

    /**
     * 节点列表
     */
    @NotEmpty(message = "审批节点不能为空")
    @Valid
    private List<NodeConfig> nodes;

    /**
     * 节点配置
     */
    @Data
    public static class NodeConfig {

        /**
         * 节点名称
         */
        @NotBlank(message = "节点名称不能为空")
        private String nodeName;

        /**
         * 节点顺序
         */
        @NotNull(message = "节点顺序不能为空")
        private Integer nodeOrder;

        /**
         * 审批人类型: USER/POSITION/DEPARTMENT_HEAD
         */
        @NotBlank(message = "审批人类型不能为空")
        private String approverType;

        /**
         * 指定审批人/职位ID
         */
        private Long approverId;
    }
}
