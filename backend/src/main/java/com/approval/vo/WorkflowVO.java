package com.approval.vo;

import com.approval.entity.WorkflowTemplate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 工作流模板视图对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkflowVO {

    /**
     * 模板ID
     */
    private Long id;

    /**
     * 模板名称
     */
    private String name;

    /**
     * 关联审批类型编码
     */
    private String typeCode;

    /**
     * 审批类型名称
     */
    private String typeName;

    /**
     * 模板描述
     */
    private String description;

    /**
     * 状态: 0-禁用 1-启用
     */
    private Integer status;

    /**
     * 节点数量
     */
    private Integer nodeCount;

    /**
     * 创建人ID
     */
    private Long createdBy;

    /**
     * 创建人名称
     */
    private String createdByName;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    /**
     * 节点列表（详情时返回）
     */
    private List<WorkflowNodeVO> nodes;

    /**
     * 从实体转换为VO（不含节点）
     *
     * @param entity 工作流模板实体
     * @return 工作流模板VO
     */
    public static WorkflowVO from(WorkflowTemplate entity) {
        if (entity == null) {
            return null;
        }
        return WorkflowVO.builder()
                .id(entity.getId())
                .name(entity.getName())
                .typeCode(entity.getTypeCode())
                .description(entity.getDescription())
                .status(entity.getStatus())
                .createdBy(entity.getCreatedBy())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
