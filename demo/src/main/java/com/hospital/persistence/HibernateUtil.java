package com.hospital.persistence;

import org.hibernate.SessionFactory;
import org.hibernate.boot.MetadataSources;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;

public final class HibernateUtil {

    private static final SessionFactory SESSION_FACTORY = buildSessionFactory();

    private HibernateUtil() {
    }

    private static SessionFactory buildSessionFactory() {
        var builder = new StandardServiceRegistryBuilder()
                .configure("hibernate.cfg.xml");

        String password = System.getenv("HOSPITAL_DB_PASSWORD");
        if (password != null) {
            builder.applySetting("hibernate.connection.password", password);
        } else {
            String prop = System.getProperty("hospital.db.password");
            if (prop != null) {
                builder.applySetting("hibernate.connection.password", prop);
            }
        }

        String url = System.getenv("HOSPITAL_DB_URL");
        if (url != null) {
            builder.applySetting("hibernate.connection.url", url);
        }
        String user = System.getenv("HOSPITAL_DB_USER");
        if (user != null) {
            builder.applySetting("hibernate.connection.username", user);
        }

        var built = builder.build();
        try {
            return new MetadataSources(built)
                    .buildMetadata()
                    .getSessionFactoryBuilder()
                    .build();
        } catch (Exception e) {
            System.err.println("[Hospital] Hibernate SessionFactory init failed.");
            System.err.println("[Hospital] Tip: ensure MySQL is running and credentials are set.");
            System.err.println("[Hospital] - hibernate.cfg.xml user/url, or env HOSPITAL_DB_USER/HOSPITAL_DB_URL");
            System.err.println("[Hospital] - password via env HOSPITAL_DB_PASSWORD or JVM -Dhospital.db.password");
            e.printStackTrace(System.err);
            StandardServiceRegistryBuilder.destroy(built);
            throw new ExceptionInInitializerError(e);
        }
    }

    public static SessionFactory getSessionFactory() {
        return SESSION_FACTORY;
    }
}
