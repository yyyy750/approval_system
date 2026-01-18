package com.approval.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 最近活动VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecentActivityVO {

    /**
     * 审批ID
     */
    private String approvalId;

    /**
     * 活动类型: created-发起, approved-通过, rejected-拒绝, withdrawn-撤回
     */
    private String activityType;

    /**
     * 审批标题
     */
    private String title;

    /**
     * 审批类型名称
     */
    private String typeName;

    /**
     * 审批类型图标
     */
    private String typeIcon;

    /**
     * 审批类型颜色
     */
    private String typeColor;

    /**
     * 活动时间
     */
    private LocalDateTime activityTime;

    /**
     * 状态码
     */
    private Integer status;

    /**
     * 相对时间描述 (如: 2小时前)
     */
    private String relativeTime;
}
