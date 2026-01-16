package com.approval.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 创建/更新审批类型请求DTO
 */
@Data
public class ApprovalTypeRequest {

    /**
     * 类型编码
     */
    @NotBlank(message = "类型编码不能为空")
    private String code;

    /**
     * 类型名称
     */
    @NotBlank(message = "类型名称不能为空")
    private String name;

    /**
     * 类型描述
     */
    private String description;

    /**
     * 图标名称
     */
    private String icon;

    /**
     * 主题颜色
     */
    private String color;

    /**
     * 状态: 0-禁用 1-启用
     */
    private Integer status;
}
