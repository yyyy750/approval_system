package com.approval.service.impl;

import com.approval.dto.WorkflowCreateRequest;
import com.approval.dto.WorkflowUpdateRequest;
import com.approval.entity.ApprovalType;
import com.approval.entity.SysUser;
import com.approval.entity.WorkflowNodeTemplate;
import com.approval.entity.WorkflowTemplate;
import com.approval.exception.BusinessException;
import com.approval.mapper.*;
import com.approval.service.WorkflowService;
import com.approval.vo.WorkflowNodeVO;
import com.approval.vo.WorkflowVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 工作流服务实现类
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WorkflowServiceImpl implements WorkflowService {

    private final WorkflowTemplateMapper workflowTemplateMapper;
    private final WorkflowNodeTemplateMapper workflowNodeTemplateMapper;
    private final ApprovalTypeMapper approvalTypeMapper;
    private final SysUserMapper sysUserMapper;
    private final SysPositionMapper sysPositionMapper;

    @Override
    public IPage<WorkflowVO> getWorkflowList(int page, int pageSize, String typeCode, Integer status) {
        LambdaQueryWrapper<WorkflowTemplate> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(typeCode)) {
            wrapper.eq(WorkflowTemplate::getTypeCode, typeCode);
        }
        if (status != null) {
            wrapper.eq(WorkflowTemplate::getStatus, status);
        }
        wrapper.orderByDesc(WorkflowTemplate::getCreatedAt);

        Page<WorkflowTemplate> pageParam = new Page<>(page, pageSize);
        IPage<WorkflowTemplate> resultPage = workflowTemplateMapper.selectPage(pageParam, wrapper);

        return resultPage.convert(template -> {
            WorkflowVO vo = WorkflowVO.from(template);
            // 获取类型名称
            ApprovalType type = getApprovalTypeByCode(template.getTypeCode());
            if (type != null) {
                vo.setTypeName(type.getName());
            }
            // 获取创建人名称
            SysUser creator = sysUserMapper.selectById(template.getCreatedBy());
            if (creator != null) {
                vo.setCreatedByName(creator.getNickname());
            }
            // 获取节点数量
            LambdaQueryWrapper<WorkflowNodeTemplate> nodeWrapper = new LambdaQueryWrapper<>();
            nodeWrapper.eq(WorkflowNodeTemplate::getWorkflowId, template.getId());
            vo.setNodeCount(Math.toIntExact(workflowNodeTemplateMapper.selectCount(nodeWrapper)));
            return vo;
        });
    }

    @Override
    public WorkflowVO getWorkflowDetail(Long id) {
        WorkflowTemplate template = workflowTemplateMapper.selectById(id);
        if (template == null) {
            throw new BusinessException(5001, "工作流模版不存在");
        }

        WorkflowVO vo = WorkflowVO.from(template);

        // 获取类型名称
        ApprovalType type = getApprovalTypeByCode(template.getTypeCode());
        if (type != null) {
            vo.setTypeName(type.getName());
        }

        // 获取创建人名称
        SysUser creator = sysUserMapper.selectById(template.getCreatedBy());
        if (creator != null) {
            vo.setCreatedByName(creator.getNickname());
        }

        // 获取节点列表
        List<WorkflowNodeTemplate> nodes = workflowNodeTemplateMapper.selectByWorkflowId(id);
        List<WorkflowNodeVO> nodeVOs = nodes.stream()
                .map(node -> {
                    WorkflowNodeVO nodeVO = WorkflowNodeVO.from(node);
                    // 获取审批人/职位名称
                    nodeVO.setApproverName(resolveApproverName(node.getApproverType(), node.getApproverId()));
                    return nodeVO;
                })
                .collect(Collectors.toList());
        vo.setNodes(nodeVOs);
        vo.setNodeCount(nodeVOs.size());

        return vo;
    }

    @Override
    public WorkflowVO getWorkflowByTypeCode(String typeCode) {
        WorkflowTemplate template = workflowTemplateMapper.selectByTypeCode(typeCode);
        if (template == null) {
            return null;
        }
        return getWorkflowDetail(template.getId());
    }

    @Override
    @Transactional
    public WorkflowVO createWorkflow(WorkflowCreateRequest request, Long userId) {
        // 检查类型是否存在
        ApprovalType type = getApprovalTypeByCode(request.getTypeCode());
        if (type == null) {
            throw new BusinessException(400, "审批类型不存在");
        }

        // 创建工作流模板
        WorkflowTemplate template = WorkflowTemplate.builder()
                .name(request.getName())
                .typeCode(request.getTypeCode())
                .description(request.getDescription())
                .status(request.getStatus() != null ? request.getStatus() : 1)
                .createdBy(userId)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        workflowTemplateMapper.insert(template);

        // 创建节点
        for (WorkflowCreateRequest.NodeConfig nodeConfig : request.getNodes()) {
            WorkflowNodeTemplate node = WorkflowNodeTemplate.builder()
                    .workflowId(template.getId())
                    .nodeName(nodeConfig.getNodeName())
                    .nodeOrder(nodeConfig.getNodeOrder())
                    .approverType(nodeConfig.getApproverType())
                    .approverId(nodeConfig.getApproverId())
                    .createdAt(LocalDateTime.now())
                    .build();
            workflowNodeTemplateMapper.insert(node);
        }

        log.info("用户 {} 创建工作流模板: {}", userId, template.getName());
        return getWorkflowDetail(template.getId());
    }

    @Override
    @Transactional
    public WorkflowVO updateWorkflow(Long id, WorkflowUpdateRequest request) {
        WorkflowTemplate template = workflowTemplateMapper.selectById(id);
        if (template == null) {
            throw new BusinessException(5001, "工作流模版不存在");
        }

        // 更新模板信息
        template.setName(request.getName());
        template.setDescription(request.getDescription());
        if (request.getStatus() != null) {
            template.setStatus(request.getStatus());
        }
        template.setUpdatedAt(LocalDateTime.now());
        workflowTemplateMapper.updateById(template);

        // 删除旧节点
        LambdaQueryWrapper<WorkflowNodeTemplate> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(WorkflowNodeTemplate::getWorkflowId, id);
        workflowNodeTemplateMapper.delete(deleteWrapper);

        // 创建新节点
        for (WorkflowUpdateRequest.NodeConfig nodeConfig : request.getNodes()) {
            WorkflowNodeTemplate node = WorkflowNodeTemplate.builder()
                    .workflowId(id)
                    .nodeName(nodeConfig.getNodeName())
                    .nodeOrder(nodeConfig.getNodeOrder())
                    .approverType(nodeConfig.getApproverType())
                    .approverId(nodeConfig.getApproverId())
                    .createdAt(LocalDateTime.now())
                    .build();
            workflowNodeTemplateMapper.insert(node);
        }

        log.info("更新工作流模板: {}", template.getName());
        return getWorkflowDetail(id);
    }

    @Override
    @Transactional
    public void deleteWorkflow(Long id) {
        WorkflowTemplate template = workflowTemplateMapper.selectById(id);
        if (template == null) {
            throw new BusinessException(5001, "工作流模版不存在");
        }

        // 删除节点
        LambdaQueryWrapper<WorkflowNodeTemplate> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(WorkflowNodeTemplate::getWorkflowId, id);
        workflowNodeTemplateMapper.delete(deleteWrapper);

        // 删除模板
        workflowTemplateMapper.deleteById(id);
        log.info("删除工作流模板: {}", template.getName());
    }

    @Override
    @Transactional
    public void updateWorkflowStatus(Long id, Integer status) {
        WorkflowTemplate template = workflowTemplateMapper.selectById(id);
        if (template == null) {
            throw new BusinessException(5001, "工作流模版不存在");
        }

        template.setStatus(status);
        template.setUpdatedAt(LocalDateTime.now());
        workflowTemplateMapper.updateById(template);
        log.info("更新工作流模板状态: {} -> {}", template.getName(), status == 1 ? "启用" : "禁用");
    }

    /**
     * 根据编码获取审批类型
     */
    private ApprovalType getApprovalTypeByCode(String typeCode) {
        LambdaQueryWrapper<ApprovalType> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ApprovalType::getCode, typeCode);
        return approvalTypeMapper.selectOne(wrapper);
    }

    /**
     * 解析审批人名称
     */
    private String resolveApproverName(String approverType, Long approverId) {
        if (approverId == null) {
            if ("DEPARTMENT_HEAD".equals(approverType)) {
                return "部门负责人";
            }
            return null;
        }

        switch (approverType) {
            case "USER":
                SysUser user = sysUserMapper.selectById(approverId);
                return user != null ? user.getNickname() : null;
            case "POSITION":
                var position = sysPositionMapper.selectById(approverId);
                return position != null ? position.getName() : null;
            default:
                return null;
        }
    }
}
