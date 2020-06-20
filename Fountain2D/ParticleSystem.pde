class ParticleSystem {
  ArrayList<Particle> particles;
  float genRate = 20;
  //int maxParticles = 500;

  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    for (int i=0;i<5;i++){
      particles.add(new Particle());
    }
  }

  void run() {
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      p.run();
      if (p.done()) {
        it.remove();
      }
    }
  }
}
