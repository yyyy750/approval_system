package com.approval.service.impl;

import com.approval.entity.Notification;
import com.approval.exception.BusinessException;
import com.approval.mapper.NotificationMapper;
import com.approval.service.NotificationService;
import com.approval.vo.NotificationVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 通知服务实现类
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    private final NotificationMapper notificationMapper;

    /**
     * 通知类型常量
     */
    private static final String TYPE_APPROVAL = "APPROVAL";
    private static final String TYPE_SYSTEM = "SYSTEM";

    @Override
    @Transactional
    public void sendApprovalNotification(String approvalId, Long receiverId, String title, String content) {
        Notification notification = Notification.builder()
                .userId(receiverId)
                .title(title)
                .content(content)
                .type(TYPE_APPROVAL)
                .relatedId(approvalId)
                .isRead(0)
                .createdAt(LocalDateTime.now())
                .build();
        notificationMapper.insert(notification);
        log.info("发送审批通知给用户 {}: {}", receiverId, title);
    }

    @Override
    @Transactional
    public void sendSystemNotification(Long receiverId, String title, String content) {
        Notification notification = Notification.builder()
                .userId(receiverId)
                .title(title)
                .content(content)
                .type(TYPE_SYSTEM)
                .isRead(0)
                .createdAt(LocalDateTime.now())
                .build();
        notificationMapper.insert(notification);
        log.info("发送系统通知给用户 {}: {}", receiverId, title);
    }

    @Override
    public IPage<NotificationVO> getNotifications(Long userId, int page, int pageSize, Boolean isRead) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId);
        if (isRead != null) {
            wrapper.eq(Notification::getIsRead, isRead ? 1 : 0);
        }
        wrapper.orderByDesc(Notification::getCreatedAt);

        Page<Notification> pageParam = new Page<>(page, pageSize);
        IPage<Notification> resultPage = notificationMapper.selectPage(pageParam, wrapper);

        return resultPage.convert(NotificationVO::from);
    }

    @Override
    @Transactional
    public void markAsRead(String id, Long userId) {
        Notification notification = notificationMapper.selectById(id);
        if (notification == null) {
            throw new BusinessException(4001, "通知不存在");
        }
        if (!notification.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作该通知");
        }
        if (notification.getIsRead() == 0) {
            notification.setIsRead(1);
            notification.setReadAt(LocalDateTime.now());
            notificationMapper.updateById(notification);
        }
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationMapper.markAllAsRead(userId);
        log.info("用户 {} 将所有通知标记为已读", userId);
    }

    @Override
    public int getUnreadCount(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, 0);
        return Math.toIntExact(notificationMapper.selectCount(wrapper));
    }
}
