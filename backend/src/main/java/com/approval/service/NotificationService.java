package com.approval.service;

import com.approval.vo.NotificationVO;
import com.baomidou.mybatisplus.core.metadata.IPage;

/**
 * 通知服务接口
 */
public interface NotificationService {

    /**
     * 发送审批通知
     *
     * @param approvalId 审批ID
     * @param receiverId 接收人ID
     * @param title      通知标题
     * @param content    通知内容
     */
    void sendApprovalNotification(String approvalId, Long receiverId, String title, String content);

    /**
     * 发送系统通知
     *
     * @param receiverId 接收人ID
     * @param title      通知标题
     * @param content    通知内容
     */
    void sendSystemNotification(Long receiverId, String title, String content);

    /**
     * 获取用户通知列表
     *
     * @param userId   用户ID
     * @param page     页码
     * @param pageSize 每页条数
     * @param isRead   是否已读筛选（可选）
     * @return 分页结果
     */
    IPage<NotificationVO> getNotifications(Long userId, int page, int pageSize, Boolean isRead);

    /**
     * 标记单条通知为已读
     *
     * @param id     通知ID
     * @param userId 用户ID
     */
    void markAsRead(String id, Long userId);

    /**
     * 标记所有通知为已读
     *
     * @param userId 用户ID
     */
    void markAllAsRead(Long userId);

    /**
     * 获取未读通知数量
     *
     * @param userId 用户ID
     * @return 未读数量
     */
    int getUnreadCount(Long userId);
}
