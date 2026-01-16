package com.approval.dto;

import lombok.Data;

/**
 * 工作流状态更新请求DTO
 */
@Data
public class WorkflowStatusRequest {

    /**
     * 状态: 0-禁用 1-启用
     */
    private Integer status;
}
