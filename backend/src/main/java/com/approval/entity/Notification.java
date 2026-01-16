package com.approval.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 通知实体类
 * 映射数据库表 notification
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("notification")
public class Notification {

    /**
     * 通知ID (UUID)
     */
    @TableId(type = IdType.ASSIGN_UUID)
    private String id;

    /**
     * 接收用户ID
     */
    private Long userId;

    /**
     * 通知标题
     */
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 通知类型: APPROVAL/SYSTEM/REMINDER
     */
    private String type;

    /**
     * 关联业务ID
     */
    private String relatedId;

    /**
     * 是否已读: 0-未读 1-已读
     */
    private Integer isRead;

    /**
     * 阅读时间
     */
    private LocalDateTime readAt;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
