package com.approval.vo;

import com.approval.entity.WorkflowNodeTemplate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 工作流节点模板视图对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkflowNodeVO {

    /**
     * 节点ID
     */
    private Long id;

    /**
     * 节点名称
     */
    private String nodeName;

    /**
     * 节点顺序
     */
    private Integer nodeOrder;

    /**
     * 审批人类型: USER/POSITION/DEPARTMENT_HEAD
     */
    private String approverType;

    /**
     * 审批人/职位ID
     */
    private Long approverId;

    /**
     * 审批人/职位名称
     */
    private String approverName;

    /**
     * 从实体转换为VO
     *
     * @param entity 工作流节点模板实体
     * @return 工作流节点VO
     */
    public static WorkflowNodeVO from(WorkflowNodeTemplate entity) {
        if (entity == null) {
            return null;
        }
        return WorkflowNodeVO.builder()
                .id(entity.getId())
                .nodeName(entity.getNodeName())
                .nodeOrder(entity.getNodeOrder())
                .approverType(entity.getApproverType())
                .approverId(entity.getApproverId())
                .build();
    }
}
