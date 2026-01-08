# phenotype/pagination.py
from rest_framework.pagination import PageNumberPagination

class FlexiblePagination(PageNumberPagination):
    page_size = 20 
    page_size_query_param = 'page_size' 
    max_page_size = 200         
    def get_paginated_response(self, data):

        from rest_framework.response import Response
        
        return Response({
            'count': self.page.paginator.count,             # 总记录数
            'total_pages': self.page.paginator.num_pages,   # 总页数
            'current_page': self.page.number,               # 当前页码
            'page_size': self.get_page_size(self.request),  # 当前页大小
            'next': self.get_next_link(),                   # 下一页链接
            'previous': self.get_previous_link(),           # 上一页链接
            'results': data                                 # 当前页数据
        })