package com.approval.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 仪表盘统计数据VO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatisticsVO {

    /**
     * 待处理审批数量
     */
    private Integer pending;

    /**
     * 已通过审批数量
     */
    private Integer approved;

    /**
     * 已拒绝审批数量
     */
    private Integer rejected;

    /**
     * 总审批数量
     */
    private Integer total;
}
