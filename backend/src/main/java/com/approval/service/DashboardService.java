package com.approval.service;

import com.approval.vo.DashboardStatisticsVO;
import com.approval.vo.RecentActivityVO;

import java.util.List;

/**
 * 仪表盘服务接口
 */
public interface DashboardService {

    /**
     * 获取用户的仪表盘统计数据
     *
     * @param userId 用户ID
     * @return 统计数据
     */
    DashboardStatisticsVO getStatistics(Long userId);

    /**
     * 获取用户的最近活动记录
     *
     * @param userId 用户ID
     * @param limit  返回数量限制
     * @return 最近活动列表
     */
    List<RecentActivityVO> getRecentActivities(Long userId, int limit);
}
