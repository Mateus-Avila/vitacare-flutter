class VitacareRoutes {
  static const login = '/';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const patientRegistration = '/patients/register';
  static const patientList = '/patients/list';
  static const healthRecord = '/records/register';
  static const recordsHistory = '/records/history';
  static const alerts = '/alerts';
  static const about = '/about';

  static const publicRoutes = <String>{
    login,
    register,
    forgotPassword,
  };

  static const privateRoutes = <String>{
    dashboard,
    patientRegistration,
    patientList,
    healthRecord,
    recordsHistory,
    alerts,
    about,
  };
}
