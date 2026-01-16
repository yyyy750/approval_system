package com.approval.mapper;

import com.approval.entity.ApprovalNode;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * 审批节点Mapper接口
 */
@Mapper
public interface ApprovalNodeMapper extends BaseMapper<ApprovalNode> {

    /**
     * 根据审批ID查询节点列表
     *
     * @param approvalId 审批记录ID
     * @return 节点列表（按顺序排列）
     */
    default List<ApprovalNode> selectByApprovalId(String approvalId) {
        return selectList(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ApprovalNode>()
                .eq(ApprovalNode::getApprovalId, approvalId)
                .orderByAsc(ApprovalNode::getNodeOrder));
    }

    /**
     * 获取指定审批的当前节点
     *
     * @param approvalId 审批记录ID
     * @param nodeOrder  节点顺序
     * @return 审批节点
     */
    default ApprovalNode selectCurrentNode(String approvalId, Integer nodeOrder) {
        return selectOne(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ApprovalNode>()
                .eq(ApprovalNode::getApprovalId, approvalId)
                .eq(ApprovalNode::getNodeOrder, nodeOrder));
    }
}
