package com.approval.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 审批操作请求DTO
 */
@Data
public class ApproveRequest {

    /**
     * 是否通过: true-通过 false-拒绝
     */
    @NotNull(message = "审批结果不能为空")
    private Boolean approved;

    /**
     * 审批意见
     */
    private String comment;
}
