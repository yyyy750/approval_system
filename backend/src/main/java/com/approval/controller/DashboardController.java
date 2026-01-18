package com.approval.controller;

import com.approval.common.Result;
import com.approval.mapper.SysUserMapper;
import com.approval.security.JwtTokenProvider;
import com.approval.service.DashboardService;
import com.approval.vo.DashboardStatisticsVO;
import com.approval.vo.RecentActivityVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 仪表盘控制器
 * 提供仪表盘统计数据接口
 */
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;
    private final JwtTokenProvider jwtTokenProvider;
    private final SysUserMapper sysUserMapper;

    /**
     * 获取仪表盘统计数据
     * 根据当前用户返回对应的统计信息
     *
     * @param token JWT Token
     * @return 统计数据
     */
    @GetMapping("/statistics")
    public Result<DashboardStatisticsVO> getStatistics(@RequestHeader("Authorization") String token) {
        Long userId = jwtTokenProvider.getUserIdFromToken(token.replace("Bearer ", ""), sysUserMapper);
        DashboardStatisticsVO statistics = dashboardService.getStatistics(userId);
        return Result.success(statistics);
    }

    /**
     * 获取最近活动记录
     *
     * @param token JWT Token
     * @param limit 返回数量限制
     * @return 最近活动列表
     */
    @GetMapping("/recent-activities")
    public Result<List<RecentActivityVO>> getRecentActivities(
            @RequestHeader("Authorization") String token,
            @RequestParam(defaultValue = "10") int limit) {
        Long userId = jwtTokenProvider.getUserIdFromToken(token.replace("Bearer ", ""), sysUserMapper);
        List<RecentActivityVO> activities = dashboardService.getRecentActivities(userId, limit);
        return Result.success(activities);
    }
}
