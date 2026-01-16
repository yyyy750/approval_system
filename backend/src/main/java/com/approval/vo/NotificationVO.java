package com.approval.vo;

import com.approval.entity.Notification;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 通知视图对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationVO {

    /**
     * 通知ID
     */
    private String id;

    /**
     * 通知标题
     */
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 通知类型
     */
    private String type;

    /**
     * 关联业务ID
     */
    private String relatedId;

    /**
     * 是否已读
     */
    private Boolean isRead;

    /**
     * 阅读时间
     */
    private LocalDateTime readAt;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 从实体转换为VO
     *
     * @param entity 通知实体
     * @return 通知VO
     */
    public static NotificationVO from(Notification entity) {
        if (entity == null) {
            return null;
        }
        return NotificationVO.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .content(entity.getContent())
                .type(entity.getType())
                .relatedId(entity.getRelatedId())
                .isRead(entity.getIsRead() == 1)
                .readAt(entity.getReadAt())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
