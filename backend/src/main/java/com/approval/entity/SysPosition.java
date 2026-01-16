package com.approval.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 职位实体类
 * 映射数据库表 sys_position
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("sys_position")
public class SysPosition {

    /**
     * 职位ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 职位编码（如DEPT_MANAGER）
     */
    private String code;

    /**
     * 职位名称
     */
    private String name;

    /**
     * 职位描述
     */
    private String description;

    /**
     * 职级（用于审批层级）
     */
    private Integer level;

    /**
     * 状态: 0-禁用 1-启用
     */
    private Integer status;

    /**
     * 排序序号
     */
    private Integer sortOrder;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
