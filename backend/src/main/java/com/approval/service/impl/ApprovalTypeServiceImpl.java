package com.approval.service.impl;

import com.approval.dto.ApprovalTypeRequest;
import com.approval.entity.ApprovalType;
import com.approval.exception.BusinessException;
import com.approval.mapper.ApprovalTypeMapper;
import com.approval.service.ApprovalTypeService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 审批类型服务实现类
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ApprovalTypeServiceImpl implements ApprovalTypeService {

    private final ApprovalTypeMapper approvalTypeMapper;

    @Override
    public List<ApprovalType> getAvailableTypes() {
        return approvalTypeMapper.selectEnabledTypes();
    }

    @Override
    public List<ApprovalType> getAllTypes() {
        return approvalTypeMapper.selectList(
                new LambdaQueryWrapper<ApprovalType>()
                        .orderByAsc(ApprovalType::getSortOrder));
    }

    @Override
    public ApprovalType getByCode(String code) {
        ApprovalType type = approvalTypeMapper.selectOne(
                new LambdaQueryWrapper<ApprovalType>()
                        .eq(ApprovalType::getCode, code)
                        .eq(ApprovalType::getStatus, 1));
        if (type == null) {
            throw new BusinessException(404, "审批类型不存在: " + code);
        }
        return type;
    }

    @Override
    public ApprovalType getById(Long id) {
        ApprovalType type = approvalTypeMapper.selectById(id);
        if (type == null) {
            throw new BusinessException(404, "审批类型不存在");
        }
        return type;
    }

    @Override
    @Transactional
    public ApprovalType create(ApprovalTypeRequest request) {
        // 检查编码是否已存在
        ApprovalType existing = approvalTypeMapper.selectOne(
                new LambdaQueryWrapper<ApprovalType>()
                        .eq(ApprovalType::getCode, request.getCode()));
        if (existing != null) {
            throw new BusinessException(400, "类型编码已存在: " + request.getCode());
        }

        ApprovalType type = ApprovalType.builder()
                .code(request.getCode())
                .name(request.getName())
                .description(request.getDescription())
                .icon(request.getIcon())
                .color(request.getColor())
                .status(request.getStatus() != null ? request.getStatus() : 1)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        approvalTypeMapper.insert(type);
        log.info("创建审批类型: {}", type.getName());
        return type;
    }

    @Override
    @Transactional
    public ApprovalType update(Long id, ApprovalTypeRequest request) {
        ApprovalType type = getById(id);

        type.setName(request.getName());
        type.setDescription(request.getDescription());
        type.setIcon(request.getIcon());
        type.setColor(request.getColor());
        if (request.getStatus() != null) {
            type.setStatus(request.getStatus());
        }
        type.setUpdatedAt(LocalDateTime.now());

        approvalTypeMapper.updateById(type);
        log.info("更新审批类型: {}", type.getName());
        return type;
    }

    @Override
    @Transactional
    public void delete(Long id) {
        ApprovalType type = getById(id);
        approvalTypeMapper.deleteById(id);
        log.info("删除审批类型: {}", type.getName());
    }
}
