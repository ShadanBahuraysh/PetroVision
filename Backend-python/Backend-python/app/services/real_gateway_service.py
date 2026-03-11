from app.patterns.proxy.gateway import IApplicationGateway

class RealGatewayService(IApplicationGateway):
    """
    هذا الكلاس هو التنفيذ الفعلي (Real Subject).
    لا يتم الوصول إليه إلا بعد تخطي طبقة الحماية في البروكسي.
    """
    
    def login(self, email, password):
        # هنا يتم تنفيذ عمليات الربط الحقيقية، فتح الجلسة (Session)، إلخ.
        print(f"[Core System] Establishing secure session for: {email}")

    def access_dashboard(self, user):
        # هنا يتم استدعاء البيانات الحقيقية من الداتا بيز للداشبورد
        print(f"[Core System] Fetching real-time data for {user.role}: {user.name}")